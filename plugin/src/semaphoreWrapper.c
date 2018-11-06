#include "semaphoreWrapper.h"

#ifndef __APPLE__

SemaphoreWrapper semaphore_create(int initialValue){
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

#endif
