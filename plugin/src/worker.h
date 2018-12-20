#ifndef __WORKER__
#define __WORKER__

#include "PThreadedPlugin.h"
#include "workerTask.h"
#include "threadSafeQueue.h"
#include "callbacks.h"

typedef struct __Worker Worker;

/*
 * Worker
 */
Worker *worker_find(char *name);
Worker *worker_new(char *name, int pharo_semaphore_index);
int worker_register(Worker *worker);
void worker_unregister(Worker *worker);
void worker_set_callback_semaphore_index(Worker *worker, int index);
void worker_dispatch_callout(Worker *worker, WorkerTask *task);
void worker_callback_return(Worker *worker, CallbackInvocation *handler); // returning from a callback
void *worker_run(void *worker); // void* because it will be transferred by pthread
void worker_add_call(Worker *worker, WorkerTask *task);
WorkerTask *worker_next_call(Worker *worker);
void worker_add_pending_callback(Worker *worker, CallbackInvocation *pendingCallback);
CallbackInvocation *worker_next_pending_callback(Worker *worker);
void worker_release(Worker *worker);

#endif
