#ifndef __WORKER__
#define __WORKER__

#include "PThreadedPlugin.h"
#include "workerTask.h"
#include "callbacks.h"
#include "semaphore.h"

typedef struct __WorkerCall {
    WorkerTask *task;
    struct __WorkerCall *next;
} WorkerCall;

typedef struct __WorkerPendingCallback {
    CallbackInvocation *invocation;
    struct __WorkerPendingCallback *next;
} WorkerPendingCallback;

typedef struct {
    pthread_t threadId;
    Semaphore semaphore;
    int callbackSemaphoreIndex;
    pthread_mutex_t queueCriticalSection;
} WorkerThread;

typedef struct __Worker {
    char *name;
    WorkerThread *thread;
    WorkerCall *call;
    WorkerPendingCallback *pendingCallback;
    struct __Worker *next;
} Worker;

/*
 * Worker
 */
Worker *worker_find(char *name);
Worker *worker_new(char *name);
int worker_register(Worker *worker);
void worker_unregister(Worker *worker);
void worker_set_callback_semaphore_index(Worker *worker, int index);
void worker_dispatch_callout(Worker *worker, WorkerTask *task);
void worker_callback_return(Worker *worker, CallbackInvocation *handler); // returning from a callback
void *worker_run(void *worker); // void* because it will be transferred by pthread
void worker_add_call(Worker *worker, WorkerTask *task);
WorkerTask *worker_next_call(Worker *worker);
void worker_add_pending_callback(Worker *worker, WorkerPendingCallback *pendingCallback);
CallbackInvocation *worker_next_pending_callback(Worker *worker);
void worker_release(Worker *worker);

/*
 * WorkerCall
 */
WorkerCall *worker_call_new(WorkerTask *task);
void worker_call_release(WorkerCall *);
/*
 * WorkerPendingCallback
 */
WorkerPendingCallback *worker_pending_callback_new(CallbackInvocation *invocation);
void worker_pending_callback_release(WorkerPendingCallback *pendingCallback);

#endif
