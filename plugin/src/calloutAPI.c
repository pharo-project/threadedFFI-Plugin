#include "PThreadedPlugin.h"

void performCallCifWithIntoUsing(void* anExternalFunction, void* aCif, void* parametersAddress, void* returnHolderAddress, int semaphoreIndex){
	WorkerTask* calloutTask = malloc(sizeof(WorkerTask));
  calloutTask->type = CALLOUT;
	calloutTask->anExternalFunction = anExternalFunction;
	calloutTask->cif = (ffi_cif*) aCif;
	calloutTask->parametersAddress = parametersAddress;
	calloutTask->returnHolderAddress = returnHolderAddress;
	calloutTask->semaphoreIndex = semaphoreIndex;
	put_queue(calloutTask);
}

void performSyncCallCifWithInto(void* anExternalFunction, void* aCif, void* parametersAddress, void* returnHolderAddress){
	ffi_call(aCif, anExternalFunction, returnHolderAddress, parametersAddress);
}


void* defineFunctionWithAnd(ffi_type* parameters[], sqInt count, void* returnType){
	ffi_cif* cif;
	int returnCode; 
	
	cif = malloc(sizeof(ffi_cif));
	
	returnCode = ffi_prep_cif(cif, FFI_DEFAULT_ABI, count, returnType, parameters);
	
	if(returnCode != FFI_OK){
		interpreterProxy->primitiveFailFor(returnCode);
		free(cif);
		free(parameters);
		return NULL;
	}
		
	return cif;
}
