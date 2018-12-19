#ifndef __SEMAPHORE__
#define __SEMAPHORE__

typedef struct __Semaphore {
	void *handle;
	void (*wait)(struct __Semaphore *semaphore);
	void (*signal)(struct __Semaphore *semaphore);
	void (*free)(struct __Semaphore *semaphore);
} Semaphore;

#endif // ifndef __SEMAPHORE__
