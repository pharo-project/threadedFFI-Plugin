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
	Runner runner;

    pthread_t threadId;
    TSQueue *taskQueue;
    struct __Worker *next;
};

void *worker_run(void *worker);
WorkerTask *worker_next_call(Worker *worker);



void worker_enter_callback(Runner* runner, CallbackInvocation* invocation){
	worker_run((Worker*)runner);
}

void worker_callback_return(Runner* worker, CallbackInvocation *invocation){
    WorkerTask *task = worker_task_new_callback();
    worker_add_call((Worker*)worker, task);
}


static void executeWorkerTask(Worker *worker, WorkerTask *task);


Worker *worker_newSpawning(int spawn) {
    Worker *worker = (Worker *)malloc(sizeof(Worker));
    
    worker->next = NULL;
    worker->threadId = 0;
    worker->taskQueue = threadsafe_queue_new(platform_semaphore_new(0));
    worker->runner.callbackEnterFunction = worker_enter_callback;
    worker->runner.callbackExitFunction = worker_callback_return;

    if(spawn){
    	if (pthread_create(&(worker->threadId), NULL, worker_run, (void *)worker) != 0) {
    		perror("pthread_create() error");
    		return NULL;
    	}

    	pthread_detach(worker->threadId);
    }

    return worker;
}

Worker *worker_new(){
	return worker_newSpawning(true);
}

void worker_release(Worker *worker) {
    threadsafe_queue_free(worker->taskQueue);
    free(worker);
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

void *worker_run(void *worker) {
    WorkerTask *task = NULL;
    
    while(true) {
        task = worker_next_call((Worker *)worker);
        if (task) {
            if (task->type == CALLOUT) {
            	executeWorkerTask((Worker *)worker, task);
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

void executeWorkerTask(Worker *worker, WorkerTask *task) {
    
    ffi_call(
             task->cif,
             task->anExternalFunction,
             task->returnHolderAddress,
             task->parametersAddress);
    
    interpreterProxy->signalSemaphoreWithIndex(task->semaphoreIndex);
    worker_task_release(task);
}
