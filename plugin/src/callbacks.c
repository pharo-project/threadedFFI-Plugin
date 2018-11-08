#include "PThreadedPlugin.h"

SemaphoreWrapper pendingCallbacks_semaphore;
CallbackInvocation* pendingCallbacks[MAX_PENDING_CALLBACKS];
int firstPendingCallback = 0;
int nextPendingCallback = 0;
int initialized = 0;
int pendingCallbackSemaphoreIndex;


void initCallbackQueue(int semaphore_index){
	
	pendingCallbackSemaphoreIndex = semaphore_index;
	
	if(initialized)
		return;
	
	pendingCallbacks_semaphore = semaphore_create(1);
    if(!isValidSemaphore(pendingCallbacks_semaphore)){
		interpreterProxy->primitiveFailFor(1);
		perror("initCallbackQueue");
		return;        
    }
    
    
	for(int i = 0; i < MAX_PENDING_CALLBACKS; i++){
		pendingCallbacks[i] = NULL;
	}
	
	initialized = 1;
}

CallbackInvocation* getNextCallback(){
	CallbackInvocation* ptr;
	
	int returncode;
	
    returncode = semaphore_wait(pendingCallbacks_semaphore);
	
	if(returncode == -1){
		interpreterProxy->primitiveFailFor(1);
		perror("getNextCallback");
		return NULL;
	}
	
	if(firstPendingCallback == nextPendingCallback){
		ptr = NULL;
	}else{
		ptr = pendingCallbacks[firstPendingCallback];
		pendingCallbacks[firstPendingCallback] = NULL;

		firstPendingCallback++;
		if(firstPendingCallback == MAX_PENDING_CALLBACKS)
			firstPendingCallback = 0;
	}
	
    semaphore_signal(pendingCallbacks_semaphore);

    return ptr;
}

void addPendingCallback(CallbackInvocation* aCallbackInvocation){
	int returncode;
	
    returncode = semaphore_wait(pendingCallbacks_semaphore);
	
	if(returncode == -1){
		interpreterProxy->primitiveFailFor(1);
		perror("addPendingCallback");
		return;
	}
      
	
	pendingCallbacks[nextPendingCallback] = aCallbackInvocation;
	
	nextPendingCallback ++;
	if(nextPendingCallback == MAX_PENDING_CALLBACKS)
		nextPendingCallback = 0;
	
    semaphore_signal(pendingCallbacks_semaphore);
	
	interpreterProxy->signalSemaphoreWithIndex(pendingCallbackSemaphoreIndex);
}

void callbackFrontend(ffi_cif *cif, void *ret, void* args[], void* ptr){
	CallbackInvocation inv;
	CallbackData* data = ptr;

	inv.callback = data;
	inv.arguments = args;
	inv.returnHolder = ret;
	addPendingCallback(&inv);
	
	// Manage callouts while waiting this callback to return
	worker(NULL);
}

void* defineCallbackWithParamsCountReturnType(CallbackData** callbackData, ffi_type** parameters, sqInt count, ffi_type* returnType){
	CallbackData* data;
	int returnCode;
	
	data = malloc(sizeof(CallbackData));
	*callbackData = data; 
	
	data->parameterTypes = parameters;
	
	/* Allocate closure and bound_puts */
	data->closure = ffi_closure_alloc(sizeof(ffi_closure), &(data->functionAddress));
	
	if(data->closure == NULL){
		interpreterProxy->primitiveFailFor(1);
		free(data);
		free(parameters);
		*callbackData = NULL;
		return NULL;
	}
	
	if((returnCode = ffi_prep_cif(&data->cif, FFI_DEFAULT_ABI, count, returnType, parameters)) != FFI_OK){
		interpreterProxy->primitiveFailFor(1);
		ffi_closure_free(data->closure);
		free(data);
		free(parameters);
		*callbackData = NULL;
		return NULL;	
	}
		
	if((returnCode = ffi_prep_closure_loc(data->closure, &data->cif, callbackFrontend, data, data->functionAddress)) != FFI_OK){
		interpreterProxy->primitiveFailFor(1);
		ffi_closure_free(data->closure);
		free(data);
		free(parameters);
		*callbackData = NULL;
		return NULL;	
	}
	
	return data->functionAddress;
}

void callbackReturn(CallbackInvocation* invocation){
	WorkerTask* callbackReturnTask = malloc(sizeof(WorkerTask));
	callbackReturnTask->type = CALLBACK_RETURN;
	put_queue(callbackReturnTask);
//	semaphore_signal(invocation->semaphore);
}


void releaseCallback(CallbackData* data){
	ffi_closure_free(data->closure);
	free(data->parameterTypes);	
	free(data);	
}
