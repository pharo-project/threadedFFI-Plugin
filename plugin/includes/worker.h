#ifndef __WORKER__
#define __WORKER__

#include "PThreadedPlugin.h"
#include "workerTask.h"
#include "threadSafeQueue.h"

typedef struct __Worker Worker;

/*
 * Worker
 */
Worker *worker_newSpawning(int spawn);
Worker *worker_new();
void *worker_run(void *worker);
void worker_release(Worker *worker);
void worker_dispatch_callout(Worker *worker, WorkerTask *task);
void worker_add_call(Worker *worker, WorkerTask *task);

#endif
