#include "semaphore.h"

#ifndef __APPLE__

Semaphore semaphore_new(long initialValue){
    ptsemaphore wrapper = malloc(sizeof(sem_t));
    int returnCode;
    
    returnCode = sem_init(wrapper, 0, initialValue);
    
    if(returnCode != 0){
        return NULL;
    }
    
    return wrapper;
}


int semaphore_wait(Semaphore sem){
    int returnCode;
    while((returnCode = sem_wait(sem)) == -1  && errno == EINTR);
    return returnCode;
}

int semaphore_signal(Semaphore sem){
    return sem_post(sem);
}

int semaphore_release(Semaphore sem){
    sem_destroy(sem);
    free(sem);
    return 0;    
}

#else

Semaphore semaphore_new(long initialValue){
    return dispatch_semaphore_create(initialValue);
}

int semaphore_wait(Semaphore sem){
	dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER );
    return 0;
}

int semaphore_signal(Semaphore sem){
    dispatch_semaphore_signal(sem);
    return 0;
}

int semaphore_release(Semaphore sem){
    dispatch_release(sem);
    return 0;    
}

#endif