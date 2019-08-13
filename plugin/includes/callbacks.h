#ifndef __CALLBACKS__
#define __CALLBACKS__

#include <ffi.h>

#include "PThreadedPlugin.h"
#include "threadSafeQueue.h"
#include "semaphore.h"
#include "pharoSemaphore.h"

struct _Callback;
struct _Runner;
struct _CallbackInvocation;

typedef void (*CALLBACK_FUNCTION)(struct _Runner* runner, struct _CallbackInvocation* callback);

typedef struct _Runner {
	CALLBACK_FUNCTION callbackEnterFunction;
	CALLBACK_FUNCTION callbackExitFunction;
} Runner;

typedef struct _Callback {
    Runner* runner;
    ffi_closure *closure;
    ffi_cif cif;
    void *functionAddress;
    ffi_type **parameterTypes;
} Callback;

typedef struct _CallbackInvocation {
    Callback *callback;
    void *returnHolder;
    void **arguments;
    //Optional payload used by the runners
    void *payload;
} CallbackInvocation;

Callback *callback_new(Runner * runner, ffi_type** parameters, sqInt count, ffi_type* returnType);
void callback_release(Callback* callbackData);

CallbackInvocation *queue_next_pending_callback();

void initilizeCallbacks(int pharo_semaphore_index);

#endif
