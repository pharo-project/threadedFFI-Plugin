#ifndef __TSQUEUE__
#define __TSQUEUE__

#include "../semaphores/semaphore.h"

typedef struct __TSQueue TSQueue;

TSQueue *threadsafe_queue_new(Semaphore *semaphore);
void threadsafe_queue_put(TSQueue *queue, void *element);
void *threadsafe_queue_take(TSQueue *queue);
void threadsafe_queue_free(TSQueue *queue);

#endif
