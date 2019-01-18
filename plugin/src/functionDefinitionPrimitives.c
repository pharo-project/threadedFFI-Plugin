#include "PThreadedPlugin.h"

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

PrimitiveWithDepth(primitiveDefineFunction, 2){
    sqInt count;
    void*handler;
    sqInt idx;
    ffi_type** parameters;
    sqInt paramsArray;
    sqInt receiver;
    void*returnType;

	returnType = readAddress(interpreterProxy->stackValue(0));
	checkFailed();

	count = interpreterProxy->stSizeOf(interpreterProxy->stackValue(1));
	checkFailed();

	paramsArray = interpreterProxy->stackValue(1);
	checkFailed();

	/* The parameters are freed by the primitiveFreeDefinition, if there is an error it is freed by #defineFunction:With:And: */
	receiver = interpreterProxy->stackValue(2);
	checkFailed();

	parameters = malloc(count*sizeof(void*));
	for (idx = 0; idx < count; idx += 1) {
		parameters[idx] = (readAddress(interpreterProxy->stObjectat(paramsArray, idx + 1)));
	}
    checkFailed()

	handler = defineFunctionWithAnd(parameters, count, returnType);
    checkFailed();

	setHandler(receiver, handler);
	checkFailed();

	primitiveEnd();
}

PrimitiveWithDepth(primitiveFreeDefinition, 1){
    void*handler;
    sqInt receiver;

	receiver = interpreterProxy->stackValue(0);
	checkFailed();

	handler = getHandler(receiver);
	checkFailed();

	if(!handler){
		interpreterProxy->primitiveFail();
		return;
	}

	free(((ffi_cif*)handler)->arg_types);
	free(handler);

	setHandler(receiver, 0);
}
