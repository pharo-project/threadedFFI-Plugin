#ifndef __CALLBACKS__
#define __CALLBACKS__

#include <ffi.h>

typedef struct {
    void *worker;
    ffi_closure *closure;
    ffi_cif cif;
    void *functionAddress;
    ffi_type **parameterTypes;
} Callback;

typedef struct {
    Callback *callback;
    void *returnHolder;
    void **arguments;
} CallbackInvocation;

Callback *callback_new(/*Worker*/ void *worker, ffi_type** parameters, sqInt count, ffi_type* returnType);
void callback_release(Callback* callbackData);

#endif
