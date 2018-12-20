#include "PThreadedPlugin.h"
#include "callbacks.h"
#include "worker.h"

static void callbackFrontend(ffi_cif *cif, void *ret, void* args[], void* cbPtr) {
	CallbackInvocation invocation;
	Callback *callback = cbPtr;

	invocation.callback = callback;
	invocation.arguments = args;
	invocation.returnHolder = ret;
	worker_add_pending_callback(callback->worker, &invocation);
	
	// Manage callouts while waiting this callback to return
	worker_run(callback->worker);
}

Callback *callback_new(void *worker, ffi_type** parameters, sqInt count, ffi_type* returnType) {
    Callback *callback = malloc(sizeof(Callback));
    int returnCode;
    
    callback->worker = worker;
    callback->parameterTypes = parameters;
    
    // Allocate closure and bound_puts
    callback->closure = ffi_closure_alloc(sizeof(ffi_closure), &(callback->functionAddress));
    
    if(callback->closure == NULL){
        interpreterProxy->primitiveFailFor(1);
        free(callback);
        free(parameters);
        return NULL;
    }
    
    if((returnCode = ffi_prep_cif(&callback->cif, FFI_DEFAULT_ABI, count, returnType, parameters)) != FFI_OK){
        interpreterProxy->primitiveFailFor(1);
        ffi_closure_free(callback->closure);
        free(callback);
        free(parameters);
        return NULL;
    }
    
    if((returnCode = ffi_prep_closure_loc(callback->closure, &callback->cif, callbackFrontend, callback, callback->functionAddress)) != FFI_OK){
        interpreterProxy->primitiveFailFor(1);
        ffi_closure_free(callback->closure);
        free(callback);
        free(parameters);
        return NULL;
    }
    
    return callback;
}

void callback_release(Callback *callback){
	ffi_closure_free(callback->closure);
	free(callback->parameterTypes);
	free(callback);
}
