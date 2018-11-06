#include "PThreadedPlugin.h"

/*** Function Prototypes ***/
const char* getModuleName(void);
sqInt initialiseModule(void);
sqInt primitiveCallbackReturn(void);
sqInt primitiveDefineFunction(void);
sqInt primitiveFillBasicType(void);
sqInt primitiveFreeDefinition(void);
sqInt primitiveInitializeCallbacksQueue(void);
sqInt primitivePerformCall(void);
sqInt primitivePerformSyncCall(void);
sqInt primitiveReadNextCallback(void);
sqInt primitiveRegisterCallback(void);
sqInt primitiveTypeByteSize(void);
sqInt primitiveUnregisterCallback(void);
sqInt setInterpreter(struct VirtualMachine*anInterpreter);


/*** Variables ***/

static struct VirtualMachine* interpreterProxy;
static const char *moduleName = "PThreadedPlugin * ThreadedFFI-Plugin-pt.2 (e)";



/*	Note: This is hardcoded so it can be run from Squeak.
	The module name is used for validating a module *after*
	it is loaded to check if it does really contain the module
	we're thinking it contains. This is important! */

	/* InterpreterPlugin>>#getModuleName */
const char * getModuleName(void)
{
	return moduleName;
}

sqInt initialiseModule(void)
{
	return initializeWorkerThread();
}

	/* PThreadedPlugin>>#primitiveCallbackReturn */
sqInt primitiveCallbackReturn(void)
{
    void*  handler;
    sqInt receiver;

	receiver = interpreterProxy->stackValue(0);
	handler = getHandler(receiver);
	callbackReturn(handler);
	return 0;
}

	/* PThreadedPlugin>>#primitiveDefineFunction */
sqInt primitiveDefineFunction(void)
{
    sqInt count;
    void*handler;
    sqInt idx;
    ffi_type** parameters;
    sqInt paramsArray;
    sqInt receiver;
    void*returnType;

	returnType = readAddress(interpreterProxy->stackValue(0));
	count = interpreterProxy->stSizeOf(interpreterProxy->stackValue(1));
	paramsArray = interpreterProxy->stackValue(1);

	/* The parameters are freed by the primitiveFreeDefinition, if there is an error it is freed by #defineFunction:With:And: */
	receiver = interpreterProxy->stackValue(2);
	parameters = malloc(count*sizeof(void*));
	for (idx = 0; idx < count; idx += 1) {
		parameters[idx] = (readAddress(interpreterProxy->stObjectat(paramsArray, idx + 1)));
	}
	if (interpreterProxy->failed()) {
		return null;
	}
	handler = defineFunctionWithAnd(parameters, count, returnType);
	if (interpreterProxy->failed()) {
		return null;
	}
	setHandler(receiver, handler);
	if (!(interpreterProxy->failed())) {
		interpreterProxy->pop(2);
	}
	return 0;
}

	/* PThreadedPlugin>>#primitiveFillBasicType */
sqInt primitiveFillBasicType(void)
{
	fillBasicType(interpreterProxy->stackValue(0));
	return 0;
}

	/* PThreadedPlugin>>#primitiveFreeDefinition */
sqInt primitiveFreeDefinition(void)
{
    void*handler;
    sqInt receiver;

	receiver = interpreterProxy->stackValue(0);
	handler = getHandler(receiver);
	if (handler == 0) {
		return 0;
	}
	free(((ffi_cif*)handler)->arg_types);
	free(handler);
	setHandler(receiver, 0);
	return 0;
}

	/* PThreadedPlugin>>#primitiveInitializeCallbacksQueue */
sqInt primitiveInitializeCallbacksQueue(void)
{
    int index;

	index = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0));
	initCallbackQueue(index);
	if (!(interpreterProxy->failed())) {
		interpreterProxy->pop(1);
	}
	return 0;
}

	/* PThreadedPlugin>>#primitivePerformCall */
sqInt primitivePerformCall(void)
{
    void*aCif;
    void*aExternalFunction;
    void*parametersAddress;
    void*returnHolderAddress;
    sqInt semaphoreIndex;

	semaphoreIndex = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0));
	returnHolderAddress = readAddress(interpreterProxy->stackValue(1));
	parametersAddress = readAddress(interpreterProxy->stackValue(2));
	aExternalFunction = getHandler(interpreterProxy->stackValue(3));
	aCif = getHandler(interpreterProxy->fetchPointerofObject(1, interpreterProxy->stackValue(3)));
	if (interpreterProxy->failed()) {
		return null;
	}
	performCallCifWithIntoUsing(aExternalFunction, aCif, parametersAddress, returnHolderAddress, semaphoreIndex);
	if (interpreterProxy->failed()) {
		return null;
	}
	if (!(interpreterProxy->failed())) {
		interpreterProxy->pop(4);
	}
	return 0;
}

	/* PThreadedPlugin>>#primitivePerformCall */
sqInt
primitivePerformSyncCall(void)
{
    void*aCif;
    void*aExternalFunction;
    void*parametersAddress;
    void*returnHolderAddress;

	returnHolderAddress = readAddress(interpreterProxy->stackValue(0));
	parametersAddress = readAddress(interpreterProxy->stackValue(1));
	aExternalFunction = getHandler(interpreterProxy->stackValue(2));
	aCif = getHandler(interpreterProxy->fetchPointerofObject(1, interpreterProxy->stackValue(2)));
	if (interpreterProxy->failed()) {
		return null;
	}
	performSyncCallCifWithInto(aExternalFunction, aCif, parametersAddress, returnHolderAddress);
	if (interpreterProxy->failed()) {
		return null;
	}
	if (!(interpreterProxy->failed())) {
		interpreterProxy->pop(3);
	}
	return 0;
}



	/* PThreadedPlugin>>#primitiveReadNextCallback */
sqInt primitiveReadNextCallback(void)
{
    CallbackInvocation* address;
    sqInt externalAddress;

	externalAddress = interpreterProxy->stackValue(0);
	address = getNextCallback();
	writeAddress(externalAddress, address);
	if (!(interpreterProxy->failed())) {
		interpreterProxy->pop(1);
	}
	return 0;
}

	/* PThreadedPlugin>>#primitiveRegisterCallback */
sqInt primitiveRegisterCallback(void)
{
    sqInt callbackData;
    CallbackData*  callbackDataPtr;
    sqInt count;
    void*  handler;
    sqInt idx;
    sqInt paramArray;
    ffi_type**  parameters;
    sqInt receiver;
    ffi_type*  returnType;

	receiver = interpreterProxy->stackValue(0);
	callbackData = interpreterProxy->fetchPointerofObject(1, receiver);
	paramArray = interpreterProxy->fetchPointerofObject(2, receiver);
	count = interpreterProxy->stSizeOf(paramArray);

	/* The parameters are freed by the primitiveFreeDefinition, if there is an error it is freed by #defineCallback:WithParams:Count:ReturnType: */
	callbackDataPtr = NULL;
	parameters = malloc(count*sizeof(void*));
	returnType = getHandler(interpreterProxy->fetchPointerofObject(3, receiver));
	for (idx = 0; idx < count; idx += 1) {
		parameters[idx] = (getHandler(interpreterProxy->stObjectat(paramArray, idx + 1)));
	}
	if (interpreterProxy->failed()) {
		return null;
	}
	handler = defineCallbackWithParamsCountReturnType((&callbackDataPtr), parameters, count, returnType);
	if (interpreterProxy->failed()) {
		return null;
	}
	setHandler(receiver, handler);
	writeAddress(callbackData, callbackDataPtr);
	return 0;
}

	/* PThreadedPlugin>>#primitiveTypeByteSize */
sqInt primitiveTypeByteSize(void)
{
    void* handler;
    sqInt receiver;
    sqInt size;

	receiver = interpreterProxy->stackValue(0);
	handler = getHandler(receiver);
	size = getTypeByteSize(handler);
	if (!(interpreterProxy->failed())) {
		interpreterProxy->methodReturnInteger(size);
	}
	return 0;
}

	/* PThreadedPlugin>>#primitiveUnregisterCallback */
sqInt primitiveUnregisterCallback(void)
{
    sqInt callbackData;
    CallbackData*  callbackDataPtr;
    sqInt receiver;

	receiver = interpreterProxy->stackValue(0);
	callbackData = interpreterProxy->fetchPointerofObject(1, receiver);
	callbackDataPtr = readAddress(callbackData);
	releaseCallback(callbackDataPtr);
	return 0;
}


/*	Note: This is coded so that it can be run in Squeak. */

	/* InterpreterPlugin>>#setInterpreter: */
sqInt setInterpreter(struct VirtualMachine* anInterpreter)
{
    sqInt ok;

	interpreterProxy = anInterpreter;
	ok = ((interpreterProxy->majorVersion()) == (VM_PROXY_MAJOR))
	 && ((interpreterProxy->minorVersion()) >= (VM_PROXY_MINOR));

	return ok;
}
