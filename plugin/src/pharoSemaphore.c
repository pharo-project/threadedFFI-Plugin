#include "pharoSemaphore.h"
#include "sqVirtualMachine.h"
#include <stdlib.h>

// Accessing the VM Functions
extern struct VirtualMachine* interpreterProxy;

/**
 * For compatibility only
 * Waiting a pharo semaphore should only be called from the pharo process
 */
void wait_pharo_semaphore(Semaphore *semaphore){
	//NOOP
}

void signal_pharo_semaphore(Semaphore *semaphore){
	interpreterProxy->signalSemaphoreWithIndex((sqInt)semaphore->handle);
}

void free_pharo_semaphore(Semaphore *semaphore){
	free(semaphore);
}

Semaphore *make_pharo_semaphore(sqInt semaphore_index) {
	Semaphore *semaphore = (Semaphore *) malloc(sizeof(Semaphore));
	semaphore->handle = (void *)semaphore_index;
	semaphore->wait = wait_pharo_semaphore;
	semaphore->signal = signal_pharo_semaphore;
	semaphore->free = free_pharo_semaphore;
	return semaphore;
}
