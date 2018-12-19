#ifndef __TSQUEUE__
#define __TSQUEUE__

#include "semaphore.h"

typedef struct __TSQueue TSQueue;

TSQueue *make_threadsafe_queue(Semaphore *semaphore);
void put_threadsafe_queue(TSQueue *queue, void *element);
void *take_threadsafe_queue(TSQueue *queue);
void free_threadsafe_queue(TSQueue *queue);

#endif
