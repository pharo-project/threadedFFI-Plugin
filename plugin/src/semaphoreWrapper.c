#include "semaphoreWrapper.h"

#ifndef __APPLE__

SemaphoreWrapper semaphore_create(long initialValue){
    SemaphoreWrapper wrapper = malloc(sizeof(sem_t));
    int returnCode;
    
    returnCode = sem_init(wrapper, 0, initialValue);
    
    if(returnCode != 0){
        return NULL;
    }
    
    return wrapper;
}


int semaphore_wait(SemaphoreWrapper sem){
    int returnCode;
    while((returnCode = sem_wait(sem)) == -1  && errno == EINTR);
    return returnCode;
}

int semaphore_signal(SemaphoreWrapper sem){
    sem_post(sem);
}

int semaphore_release(SemaphoreWrapper sem){
    sem_destroy(sem);
    free(sem);
}

#else

SemaphoreWrapper semaphore_create(long initialValue){
    return dispatch_semaphore_create(initialValue);
} 


int semaphore_wait(SemaphoreWrapper sem){
	dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER );
    return 0;
}

int semaphore_signal(SemaphoreWrapper sem){
    dispatch_semaphore_signal(sem);
}

int semaphore_release(SemaphoreWrapper sem){
    dispatch_release(sem);
}

#endif
