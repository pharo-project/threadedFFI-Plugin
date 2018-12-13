#include "threadSafeQueue.h"
#include <pthread.h>

#define WAIT(w) semaphore_wait(w->thread->semaphore)
#define SIGNAL(w) semaphore_signal(w->thread->semaphore)
#define SIGNAL_IMAGE(w) interpreterProxy->signalSemaphoreWithIndex(w->thread->callbackSemaphoreIndex)

/**
*  A queue implemented as a linked list
**/
typedef struct __TSQueue {
    struct __TSQueueNode *first;
    struct __TSQueueNode *last;
    pthread_mutex_t mutex;
} TSQueue;

/**
*  A node in the queue
**/
typedef struct __TSQueueNode {
    void *element;
    struct __TSQueueNode *next;
} TSQueueNode;

/**
*  Create a new queue in heap
*  Returns a pointer to the newly created queue
**/
TSQueue *make_queue(){
  pthread_mutex_t mutex;
  if (pthread_mutex_init(&(mutex), NULL) != 0) {
    perror("pthread_mutex_init error in make_queue");
    return 0;
  }
  
  TSQueue *queue = (TSQueue *)malloc(sizeof(TSQueue));
  queue->mutex = mutex;
  queue->first = NULL;
  queue->last = NULL; 
  return queue;
}

/**
*  Free a queue in heap and all its nodes
*  Does not free the elements pointed by the nodes, as they are owned by the user
*  Fails if pointer is invalid
**/
void free_threadsafe_queue(TSQueue *queue){
  pthread_mutex_t mutex = queue->mutex;
  pthread_mutex_lock(&mutex);
  TSQueueNode *node = queue->first;
  TSQueueNode *next_node = node;
  while(node){
    next_node = node->next;
    free(node);
    node = next_node;
  }
  free(queue);
  pthread_mutex_unlock(&mutex);
}

/**
*  Put an element at the end of in the thread safe queue
*  Only one process may modify the queue at a single point in time
*  Allocates a new node and puts the element into it
**/
void put_threadsafe_queue(TSQueue *queue, void *element){
    TSQueueNode *node = (TSQueueNode *)malloc(sizeof(TSQueueNode));
    node->element = element;
    
    pthread_mutex_lock(&(queue->mutex));
    if (!queue->first) {
      queue->first = node;
      queue->last = node;
    } else {
      queue->last->next = node;
      queue->last = node;
    }
    pthread_mutex_unlock(&(queue->mutex));
}

/**
*  Take the first element from the thread safe queue
*  Only one process may modify the queue at a single point in time
*  Frees the node and returns the element stored in it
**/
void *take_threadsafe_queue(TSQueue *queue){
  TSQueueNode *node = queue->first;
  void *element = node->element;
  
  pthread_mutex_lock(&(queue->mutex));
  if (queue->first == queue->last) {
    queue->first = NULL;
    queue->last = NULL;
  } else {
    queue->first = node->next;
  }
  pthread_mutex_unlock(&(queue->mutex));
  free(node);
  return element;
}