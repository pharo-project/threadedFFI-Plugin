#ifndef __WORKER__
#define __WORKER__

#include "PThreadedPlugin.h"
#include "workerTask.h"
#include "callbacks.h"
#include "semaphore.h"

typedef struct __TSQueue TSQueue;

TSQueue *make_threadsafe_queue();
void put_threadsafe_queue(TSQueue *queue, void *element);
void *take_threadsafe_queue(TSQueue *queue);
void free_threadsafe_queue(TSQueue *queue);

#endif
