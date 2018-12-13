#ifndef __SEMAPHORE_WRAPPER__
#define __SEMAPHORE_WRAPPER__

#include "semaphore.h"
#include <stdlib.h>

#ifndef __APPLE__
// I am a normal unix
#include <pthread.h>
#include <semaphore.h>
#include <errno.h>

typedef sem_t* PlatformSemaphore;
#define isValidSemaphore(aSemaphore) (aSemaphore != NULL)
#else
// I am OSX
#include <dispatch/dispatch.h>

typedef dispatch_semaphore_t PlatformSemaphore;
#define isValidSemaphore(aSemaphore) (1)
#endif // ifndef __APPLE__

PlatformSemaphore semaphore_new(long initialValue);
int semaphore_wait(PlatformSemaphore sem);
int semaphore_signal(PlatformSemaphore sem);
int semaphore_release(PlatformSemaphore sem);

Semaphore *make_platform_semaphore(int initialValue);

#endif // ifndef __SEMAPHORE_WRAPPER__
