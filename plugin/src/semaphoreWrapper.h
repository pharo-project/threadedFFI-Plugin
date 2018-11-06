
//#include <dispatch/dispatch.h>

#ifndef __SEMAPHORE_WRAPPER__

#define __SEMAPHORE_WRAPPER__

#ifndef __APPLE__

#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <errno.h>

typedef sem_t * SemaphoreWrapper;
#define isValidSemaphore(aSemaphore) (aSemaphore !=NULL)

SemaphoreWrapper semaphore_create(int initialValue);
int semaphore_wait(SemaphoreWrapper sem);
int semaphore_signal(SemaphoreWrapper sem);
int semaphore_release(SemaphoreWrapper sem);

#endif // ifndef __APPLE__

#endif // ifndef __SEMAPHORE_WRAPPER__
