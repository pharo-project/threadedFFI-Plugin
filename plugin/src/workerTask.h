#ifndef __WORKERTASK__
#define __WORKERTASK__

#include <ffi.h>

typedef enum {
    CALLOUT,
    CALLBACK_RETURN
} WorkerTaskType;

typedef enum {
    QUEUE_NONE,
    QUEUE_MAIN,
    QUEUE_REGISTERED
} QueueType;

typedef struct {
    WorkerTaskType type;
    void *anExternalFunction;
    ffi_cif *cif;
    void *parametersAddress;
    void *returnHolderAddress;
    int semaphoreIndex;
    QueueType queueType;
    void *queueHandle; //NULL unless useQueue == QUEUE_REGISTERED
} WorkerTask;

WorkerTask *worker_task_new(void *externalFunction, ffi_cif *cif, void *parameters, void *returnHolder, int semaphoreIndex);
WorkerTask *worker_task_new_callback();
void worker_task_release(WorkerTask *task);
void worker_task_set_main_queue(WorkerTask *task);
void worker_task_set_queue(WorkerTask *task, void *queueHandle);

#endif
