#include "pharoSemaphore.h"

#include "sqVirtualMachine.h"
#include <stdio.h>
#include <stdlib.h>

// Accessing the VM Functions
extern struct VirtualMachine* interpreterProxy;

/**
 * For compatibility only
 * Waiting a pharo semaphore should only be called from the pharo process
 */
int pharo_semaphore_wait(Semaphore *semaphore){
	//Do nothing, pharo does not wait for a semaphore in here
	//Scheduling happens in the VM
	return 0;
}

int pharo_semaphore_signal(Semaphore *semaphore){
	interpreterProxy->signalSemaphoreWithIndex((sqInt)semaphore->handle);
	return interpreterProxy->failed()? -1 : 0;
}

void pharo_semaphore_free(Semaphore *semaphore){
	free(semaphore);
}

Semaphore *pharo_semaphore_new(sqInt semaphore_index) {
	Semaphore *semaphore = (Semaphore *) malloc(sizeof(Semaphore));
	semaphore->handle = (void *)semaphore_index;
	semaphore->wait = pharo_semaphore_wait;
	semaphore->signal = pharo_semaphore_signal;
	semaphore->free = pharo_semaphore_free;
	return semaphore;
}
