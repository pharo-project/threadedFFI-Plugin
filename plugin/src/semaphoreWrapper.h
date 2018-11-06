
#ifndef __SEMAPHORE_WRAPPER__

#define __SEMAPHORE_WRAPPER__

#ifndef __APPLE__

// I am a normal unix

#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <errno.h>

typedef sem_t * SemaphoreWrapper;
#define isValidSemaphore(aSemaphore) (aSemaphore !=NULL)

#else

// I am OSX

#include <dispatch/dispatch.h>

typedef dispatch_semaphore SemaphoreWrapper;
#define isValidSemaphore(aSemaphore) (1)

#endif // ifndef __APPLE__

SemaphoreWrapper semaphore_create(long initialValue);
int semaphore_wait(SemaphoreWrapper sem);
int semaphore_signal(SemaphoreWrapper sem);
int semaphore_release(SemaphoreWrapper sem);

#endif // ifndef __SEMAPHORE_WRAPPER__
