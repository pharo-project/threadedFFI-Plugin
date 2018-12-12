
#ifndef __SEMAPHORE_WRAPPER__
#define __SEMAPHORE_WRAPPER__

#ifndef __APPLE__
// I am a normal unix
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <errno.h>

typedef sem_t* Semaphore;
#define isValidSemaphore(aSemaphore) (aSemaphore != NULL)
#else
// I am OSX
#include <dispatch/dispatch.h>

typedef dispatch_semaphore_t Semaphore;
#define isValidSemaphore(aSemaphore) (1)
#endif // ifndef __APPLE__

Semaphore semaphore_new(long initialValue);
int semaphore_wait(Semaphore sem);
int semaphore_signal(Semaphore sem);
int semaphore_release(Semaphore sem);

#endif // ifndef __SEMAPHORE_WRAPPER__
