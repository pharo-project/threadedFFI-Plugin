#include "PThreadedPlugin.h"
#include "callbacks.h"
#include "worker.h"

static void callbackFrontend(ffi_cif *cif, void *ret, void* args[], void* cbPtr) {
	CallbackInvocation invocation;
	Callback *callback = cbPtr;

	invocation.callback = callback;
	invocation.arguments = args;
	invocation.returnHolder = ret;
	worker_add_pending_callback(callback->worker, worker_pending_callback_new(&invocation));
	
	// Manage callouts while waiting this callback to return
	worker_run(callback->worker);
}

Callback *callback_new(void *worker, ffi_type** parameters, sqInt count, ffi_type* returnType) {
    Callback *data = malloc(sizeof(Callback));
    int returnCode;
    
    data->worker = worker;
    data->parameterTypes = parameters;
    
    // Allocate closure and bound_puts
    data->closure = ffi_closure_alloc(sizeof(ffi_closure), &(data->functionAddress));
    
    if(data->closure == NULL){
        interpreterProxy->primitiveFailFor(1);
        free(data);
        free(parameters);
        return NULL;
    }
    
    if((returnCode = ffi_prep_cif(&data->cif, FFI_DEFAULT_ABI, count, returnType, parameters)) != FFI_OK){
        interpreterProxy->primitiveFailFor(1);
        ffi_closure_free(data->closure);
        free(data);
        free(parameters);
        return NULL;
    }
    
    if((returnCode = ffi_prep_closure_loc(data->closure, &data->cif, callbackFrontend, data, data->functionAddress)) != FFI_OK){
        interpreterProxy->primitiveFailFor(1);
        ffi_closure_free(data->closure);
        free(data);
        free(parameters);
        return NULL;
    }
    
    return data;
}

void callback_release(Callback *data){
	ffi_closure_free(data->closure);
	free(data->parameterTypes);	
	free(data);	
}
