
#ifndef __SEMAPHORE_WRAPPER__
#define __SEMAPHORE_WRAPPER__

#ifndef __APPLE__
// I am a normal unix
#include <stdlib.h>
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

#endif // ifndef __SEMAPHORE_WRAPPER__
