#include "platformSemaphore.h"

#ifndef __APPLE__

PlatformSemaphore semaphore_new(long initialValue){
    ptsemaphore wrapper = malloc(sizeof(sem_t));
    int returnCode;
    
    returnCode = sem_init(wrapper, 0, initialValue);
    
    if(returnCode != 0){
        return NULL;
    }
    
    return wrapper;
}


int semaphore_wait(PlatformSemaphore sem){
    int returnCode;
    while((returnCode = sem_wait(sem)) == -1  && errno == EINTR);
    return returnCode;
}

int semaphore_signal(PlatformSemaphore sem){
    return sem_post(sem);
}

int semaphore_release(PlatformSemaphore sem){
    sem_destroy(sem);
    free(sem);
    return 0;    
}

#else

PlatformSemaphore semaphore_new(long initialValue){
    return dispatch_semaphore_create(initialValue);
}

int semaphore_wait(PlatformSemaphore sem){
	dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER );
    return 0;
}

int semaphore_signal(PlatformSemaphore sem){
    dispatch_semaphore_signal(sem);
    return 0;
}

int semaphore_release(PlatformSemaphore sem){
    dispatch_release(sem);
    return 0; 
}

#endif

void wait_platform_semaphore(Semaphore *semaphore){
	semaphore_wait((PlatformSemaphore)semaphore->handle);
}

void signal_platform_semaphore(Semaphore *semaphore){
	semaphore_signal((PlatformSemaphore)semaphore->handle);
}

void free_platform_semaphore(Semaphore *semaphore){
	semaphore_release((PlatformSemaphore)semaphore->handle);
	free(semaphore);
}

Semaphore *make_platform_semaphore(int initialValue) {
	Semaphore *semaphore = (Semaphore *) malloc(sizeof(Semaphore));
	semaphore->handle = (void *) semaphore_new(initialValue);
	semaphore->wait = wait_platform_semaphore;
	semaphore->signal = signal_platform_semaphore;
	semaphore->free = free_platform_semaphore;
	return semaphore;
}
