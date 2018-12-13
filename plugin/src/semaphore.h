#ifndef __SEMAPHORE
#define __SEMAPHORE

typedef struct __Semaphore {
	void *handle;
	void (*wait)(struct __Semaphore *semaphore);
	void (*signal)(struct __Semaphore *semaphore);
	void (*free)(struct __Semaphore *semaphore);
} Semaphore;

#endif // ifndef __SEMAPHORE
