#include "PThreadedPlugin.h"

void performCallCifWithIntoUsing(void* anExternalFunction, void* aCif, void* parametersAddress, void* returnHolderAddress, int semaphoreIndex){
	AsyncCallParameters* asyncCallParameters = malloc(sizeof(AsyncCallParameters));
	asyncCallParameters->anExternalFunction = anExternalFunction;
	asyncCallParameters->cif = (ffi_cif*) aCif;
	asyncCallParameters->parametersAddress = parametersAddress;
	asyncCallParameters->returnHolderAddress = returnHolderAddress;
	asyncCallParameters->semaphoreIndex = semaphoreIndex;
	put_queue(asyncCallParameters);
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
