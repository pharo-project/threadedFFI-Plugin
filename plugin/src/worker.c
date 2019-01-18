#include "worker.h"

#include "threadSafeQueue.h"
#include "pharoSemaphore.h"
#include "platformSemaphore.h"
#include <stdio.h>
#include <ffi.h>
#include <pthread.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#ifdef __APPLE__
# include <dispatch/dispatch.h>
#endif

struct __Worker {
    char *name;
    pthread_t threadId;
    TSQueue *taskQueue;
    TSQueue *callbackQueue;
    struct __Worker *next;
};

#define SIGNAL_IMAGE(w) interpreterProxy->signalSemaphoreWithIndex(w->thread->callbackSemaphoreIndex)

static Worker *first = NULL;
static Worker *last = NULL;

static int runWorkerThread(Worker *worker);
static void appendWorkerToList(Worker *worker);
static void executeBasicTask(Worker *worker, WorkerTask *task);
static void executeTaskInQueue(Worker *worker, WorkerTask *task);
static inline void executeTask(Worker *worker, WorkerTask *task);

// Init/Free

Worker *worker_new(char *name, int pharo_semaphore_index) {
    Worker *worker = (Worker *)malloc(sizeof(Worker));
    
    worker->name = strdup(name);
    worker->next = NULL;
    worker->taskQueue = threadsafe_queue_new(platform_semaphore_new(0));
    worker->threadId = 0;
    worker_set_callback_semaphore_index(worker, pharo_semaphore_index);
    
    return worker;
}

void worker_release(Worker *worker) {
    
    if(worker->name) {
        free(worker->name);
    }
    threadsafe_queue_free(worker->taskQueue);
    threadsafe_queue_free(worker->callbackQueue);
    free(worker);
}

void worker_set_callback_semaphore_index(Worker *worker, int index) {
	worker->callbackQueue = threadsafe_queue_new(pharo_semaphore_new(index));
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

    if(pthread_cancel(worker->threadId) != 0) {
        interpreterProxy->primitiveFail();
    }
}

inline void worker_dispatch_callout(Worker *worker, WorkerTask *task) {
    worker_add_call(worker, task);
}

void worker_add_call(Worker *worker, WorkerTask *task) {
    threadsafe_queue_put(worker->taskQueue, task);
}

WorkerTask *worker_next_call(Worker *worker) {
	return (WorkerTask *)threadsafe_queue_take(worker->taskQueue);
}

void worker_add_pending_callback(Worker *worker, CallbackInvocation *callback) {
	threadsafe_queue_put(worker->callbackQueue, callback);
}

CallbackInvocation *worker_next_pending_callback(Worker *worker) {
    CallbackInvocation *invocation = (CallbackInvocation *) threadsafe_queue_take(worker->callbackQueue);
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

int runWorkerThread(Worker *worker) {
    if (pthread_create(&(worker->threadId), NULL, worker_run, (void *)worker) != 0) {
        perror("pthread_create() error");
        return 0;
    }
    
    pthread_detach(worker->threadId);

    return 1;
}

void appendWorkerToList(Worker *worker) {
    
    if (!first) {
        first = last = worker;
    } else {
        last->next = worker;
        last = worker;
    }
}
void executeBasicTask(Worker *worker, WorkerTask *task) {
    
    ffi_call(
             task->cif,
             task->anExternalFunction,
             task->returnHolderAddress,
             task->parametersAddress);
    
    //TODO: semaphore should be part of worker
    interpreterProxy->signalSemaphoreWithIndex(task->semaphoreIndex);
    worker_task_release(task);
}

void executeTaskInQueue(Worker *worker, WorkerTask *task) {
#ifdef __APPLE__
    dispatch_sync(task->queueType == QUEUE_MAIN ? dispatch_get_main_queue() : task->queueHandle,
                  ^{ executeBasicTask(worker, task); });
#else
    return;
#endif
}

void executeTask(Worker *worker, WorkerTask *task) {
    
    if (task->queueType == QUEUE_NONE) {
        executeBasicTask(worker, task);
    } else {
        executeTaskInQueue(worker, task);
    }
}
