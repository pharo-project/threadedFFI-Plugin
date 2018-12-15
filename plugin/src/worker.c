#include "worker.h"

#include <stdio.h>
#include <ffi.h>
#include <pthread.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#ifdef __APPLE__
# include <dispatch/dispatch.h>
#endif

#define LOCK(w) pthread_mutex_lock(&(w->thread->criticalSection))
#define UNLOCK(w) pthread_mutex_unlock(&(w->thread->criticalSection))
#define WAIT(w) semaphore_wait(w->thread->semaphore)
#define SIGNAL(w) semaphore_signal(w->thread->semaphore)
#define SIGNAL_IMAGE(w) interpreterProxy->signalSemaphoreWithIndex(w->thread->callbackSemaphoreIndex)

static Worker *first = NULL;
static Worker *last = NULL;

static int runWorkerThread(Worker *worker);
static void releaseCall(WorkerCall *call, bool deep);
static void releaseAllCalls(WorkerCall *firstCall);
static void releaseAllPendingCallbacks(WorkerPendingCallback *firstPendingCallback);
static void appendWorkerToList(Worker *worker);
static void executeBasicTask(Worker *worker, WorkerTask *task);
static void executeTaskInQueue(Worker *worker, WorkerTask *task);
static inline void executeTask(Worker *worker, WorkerTask *task);

// Init/Free

Worker *worker_new(char *name) {
    Worker *worker = (Worker *)malloc(sizeof(Worker));
    
    worker->name = strdup(name);
    worker->next = NULL;
    worker->call = NULL;
    worker->pendingCallback = NULL;
    worker->thread = (WorkerThread *)malloc(sizeof(WorkerThread));
    worker->thread->callbackSemaphoreIndex = 0;
    
    return worker;
}

void worker_release(Worker *worker) {
    
    if(worker->name) {
        free(worker->name);
    }
    if(worker->call) {
        releaseAllCalls(worker->call);
    }
    if(worker->pendingCallback) {
        releaseAllPendingCallbacks(worker->pendingCallback);
    }
    free(worker->thread);
    free(worker);
}

void worker_set_callback_semaphore_index(Worker *worker, int index) {
    worker->thread->callbackSemaphoreIndex = index;
}

Worker *worker_find(char *name) {
    Worker *worker = first;
    
    while(worker) {
        if(strcmp(worker->name, name) == 0) {
            return worker;
        }
        worker = worker->next;
    }
    
    return NULL;
}

void worker_callback_return(Worker *worker, CallbackInvocation *invocation){
    WorkerTask *task = worker_task_new_callback();
    worker_add_call(worker, task);
}

// registering

int worker_register(Worker *worker) {
    
    if(!runWorkerThread(worker)) {
        return 0;
    }
    
    appendWorkerToList(worker);
    return 1;
}

void worker_unregister(Worker *worker) {
    Worker *prevWorker = first;

    // Remove worker from list
    if(worker == first) {
        first = first->next;
    } else {
        while(prevWorker->next != worker) {
            prevWorker = prevWorker->next;
        }
        prevWorker->next = worker->next;
    }
    // Update last if needed
    if(worker == last) {
        last = prevWorker;
    }

    //Destroy pthread
    semaphore_release(worker->thread->semaphore);
    pthread_mutex_destroy(&worker->thread->criticalSection);
    if(pthread_cancel(worker->thread->threadId)) {
        interpreterProxy->primitiveFail();
    }
}

inline void worker_dispatch_callout(Worker *worker, WorkerTask *task) {
    worker_add_call(worker, task);
}

void worker_add_call(Worker *worker, WorkerTask *task) {
    WorkerCall *call = worker_call_new(task);
    
    LOCK(worker);
    if (!worker->call) {
        worker->call = call;
    } else {
        WorkerCall *last = worker->call;
        while (last->next) {
            last = last->next;
        }
        last->next = call;
    }

    UNLOCK(worker);
    SIGNAL(worker);
}

WorkerTask *worker_next_call(Worker *worker) {
    WorkerTask *task = NULL;
    
    LOCK(worker);

    if (!worker->call) {
        UNLOCK(worker);
        WAIT(worker);
        LOCK(worker);
    }
    
    WorkerCall *current = worker->call;
    if(!current) {
        UNLOCK(worker);
        return NULL;
    }
    
    task = current->task;
    worker->call = current->next;
    releaseCall(current, false);
    
    UNLOCK(worker);

    return task;
}

void worker_add_pending_callback(Worker *worker, WorkerPendingCallback *pendingCallback) {

    LOCK(worker);

    if (!worker->pendingCallback) {
        worker->pendingCallback = pendingCallback;
    } else {
        WorkerPendingCallback *last = worker->pendingCallback;
        while (last->next) {
            last = last->next;
        }
        last->next = pendingCallback;
    }
    
    UNLOCK(worker);

    SIGNAL_IMAGE(worker);
}

CallbackInvocation *worker_next_pending_callback(Worker *worker) {
    CallbackInvocation *invocation = NULL;
    
    LOCK(worker);
    
    if (worker->pendingCallback) {
        WorkerPendingCallback *current = worker->pendingCallback;
        
        invocation = current->invocation;
        worker->pendingCallback = current->next;
        
        worker_pending_callback_release(current);
    }
    
    UNLOCK(worker);
    
    return invocation;
}

void *worker_run(void *worker) {
    WorkerTask *task = NULL;
    
    while(true) {
        task = worker_next_call((Worker *)worker);
        if (task) {
            if (task->type == CALLOUT) {
                executeTask((Worker *)worker, task);
            } else if (task->type == CALLBACK_RETURN) {
                // stop consuming tasks and return
                return NULL;
            } else {
                fprintf(stderr, "Unsupported task type: %d", task->type);
                perror("");
            }
        } else {
            perror("No callbacks in the queue");
        }
    }
    
    return NULL;
}

static int runWorkerThread(Worker *worker) {

    worker->thread->semaphore = semaphore_new(1);
    if (!worker->thread->semaphore) {
        interpreterProxy->primitiveFailFor(1);
        perror("semaphore_new");
        return 0;
    }

    if (pthread_mutex_init(&(worker->thread->criticalSection), NULL) != 0) {
        perror("pthread_mutex_init(&worker->thread->criticalSection) error");
        return 0;
    }

    // I will lock the mutex.
    // This mutex is used by the worker to detect when it is a element in the queue
    WAIT(worker);
    
    if (pthread_create(&(worker->thread->threadId), NULL, worker_run, (void *)worker) != 0) {
        perror("pthread_create() error");
        return 0;
    }
    
    pthread_detach(worker->thread->threadId);

    return 1;
}

WorkerPendingCallback *worker_pending_callback_new(CallbackInvocation *invocation) {
    WorkerPendingCallback *pendingCallback = (WorkerPendingCallback *)malloc(sizeof(WorkerPendingCallback));
    
    pendingCallback->invocation = invocation;
    pendingCallback->next = NULL;

    return pendingCallback;
}

void worker_pending_callback_release(WorkerPendingCallback *pendingCallback) {
    free(pendingCallback);
}

WorkerCall *worker_call_new(WorkerTask *task) {
    WorkerCall *call = (WorkerCall *)malloc(sizeof(WorkerCall));

    call->task = task;
    call->next = NULL;
    
    return call;
}
void worker_call_release(WorkerCall *call) {
    free(call);
}

// statics

static void releaseCall(WorkerCall *call, bool deep) {
    
    if(deep) {
        worker_task_release(call->task);
        call->task = NULL;
    }
    worker_call_release(call);
}

static void releaseAllCalls(WorkerCall *firstCall) {
    WorkerCall *call = firstCall;
    
    while (call) {
        WorkerCall *current = call;
        call = call->next;
        releaseCall(current, true);
    }
}

static void releasePendingCallback(WorkerPendingCallback *pendingCallback, bool deep) {
    
    if(deep) {
        free(pendingCallback->invocation);
        pendingCallback->invocation = NULL;
    }
    worker_pending_callback_release(pendingCallback);
}


static void releaseAllPendingCallbacks(WorkerPendingCallback *firstPendingCallback) {
    WorkerPendingCallback *pendingCallback = firstPendingCallback;
    
    while (pendingCallback) {
        WorkerPendingCallback *current = pendingCallback;
        pendingCallback = pendingCallback->next;
        releasePendingCallback(current, true);
    }
}

static void appendWorkerToList(Worker *worker) {
    
    if (!first) {
        first = last = worker;
    } else {
        last->next = worker;
        last = worker;
    }
}

static void executeBasicTask(Worker *worker, WorkerTask *task) {
    
    ffi_call(
             task->cif,
             task->anExternalFunction,
             task->returnHolderAddress,
             task->parametersAddress);
    
    //TODO: semaphore should be part of worker
    interpreterProxy->signalSemaphoreWithIndex(task->semaphoreIndex);
    worker_task_release(task);
}

static void executeTaskInQueue(Worker *worker, WorkerTask *task) {
#ifdef __APPLE__
    dispatch_sync(
                  task->queueType == QUEUE_MAIN ? dispatch_get_main_queue() : task->queueHandle,
                  ^{ executeBasicTask(worker, task); });
#else
# error Execute FFI callout in queue not yet implemented
#endif
}

static inline void executeTask(Worker *worker, WorkerTask *task) {
    
    if (task->queueType == QUEUE_NONE) {
        executeBasicTask(worker, task);
    } else {
        executeTaskInQueue(worker, task);
    }
}
