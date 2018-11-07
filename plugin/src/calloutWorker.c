#include "PThreadedPlugin.h"

typedef struct QueueNode{
	AsyncCallParameters *calloutParameters;
	struct QueueNode *next;
} QueueNode;

typedef struct {
	QueueNode *first;
	QueueNode *last;
} Queue;

Queue queue = {0, 0};

pthread_t threadId;
pthread_mutex_t workerLock;
pthread_mutex_t queueCriticalSection;

sqInt initializeWorkerThread(){

	if (pthread_mutex_init(&workerLock, NULL) != 0){
		perror("pthread_mutex_init(&workerLock) error");
		return -1;
	}
	
	if (pthread_mutex_init(&queueCriticalSection, NULL) != 0){
		perror("pthread_mutex_init(&queueCriticalSection) error");
		return -1;
	}

	//I will lock the mutex. This mutex is used by the worker to detect when it is a element in the queue
    pthread_mutex_lock(&workerLock);

	if (pthread_create(&threadId, NULL, worker, NULL) != 0) {
		perror("pthread_create() error");
		return -1;
	}

	pthread_detach(threadId);
	return 1;
}

void* worker(void* aParameter){
	AsyncCallParameters *parameters;
	while(true){
		parameters = take_queue();
		if (parameters){
			doAsyncCall(parameters);
		} else {
			perror("No callbacks in the queue");
		}
	}
}

void* doAsyncCall(AsyncCallParameters* asyncCallParameters){

	ffi_call(asyncCallParameters->cif, asyncCallParameters->anExternalFunction, asyncCallParameters->returnHolderAddress, asyncCallParameters->parametersAddress);
	interpreterProxy->signalSemaphoreWithIndex(asyncCallParameters->semaphoreIndex);
	free(asyncCallParameters);
	return NULL;
}

AsyncCallParameters* take_queue(){
	AsyncCallParameters *calloutParameters;
	QueueNode *current;

	pthread_mutex_lock(&queueCriticalSection);
	if (!queue.first){
		// Free the queue mutex
		pthread_mutex_unlock(&queueCriticalSection);
		//Wait for new items in the queue
		pthread_mutex_lock(&workerLock);
		// Retake the queue mutex
		pthread_mutex_lock(&queueCriticalSection);
	}
	current = queue.first;

	if(!current){
		pthread_mutex_unlock(&queueCriticalSection);
		return NULL;  	
	}

	calloutParameters = current->calloutParameters;
	queue.first = current->next;
	free(current);

	if(queue.first == NULL){
		queue.last = NULL;
	}
	
	// Free the queue mutex
	pthread_mutex_unlock(&queueCriticalSection);
	
	return calloutParameters;
}

void put_queue(AsyncCallParameters* calloutParameters){
	QueueNode* current = malloc(sizeof(QueueNode));
	current->calloutParameters = calloutParameters;
	current->next=NULL;

	pthread_mutex_lock(&queueCriticalSection);
	if (queue.last){
		queue.last->next = current;    
	} else {
		queue.first = current;
	}
	queue.last = current;
	pthread_mutex_unlock(&queueCriticalSection);

	//Signal threads wanting to dequeue that there are new items
	pthread_mutex_unlock(&workerLock);
}