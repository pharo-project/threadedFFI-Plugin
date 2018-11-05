static char __buildInfo[] = "PThreadedPlugin * ThreadedFFI-Plugin-pt.2 uuid: a8ee3921-5a53-497f-9ddf-40a0311352e5 " __DATE__ ;

/* Default EXPORT macro that does nothing (see comment in sq.h): */
#define EXPORT(returnType) returnType

#define true 1
#define false 0
#define null 0  /* using 'null' because nil is predefined in Think C */

#include "PThreadedPlugin.h"

/*** Function Prototypes ***/
EXPORT(const char*) getModuleName(void);
EXPORT(sqInt) initialiseModule(void);
EXPORT(sqInt) primitiveCallbackReturn(void);
EXPORT(sqInt) primitiveDefineFunction(void);
EXPORT(sqInt) primitiveFillBasicType(void);
EXPORT(sqInt) primitiveFreeDefinition(void);
EXPORT(sqInt) primitiveInitializeCallbacksQueue(void);
EXPORT(sqInt) primitivePerformCall(void);
EXPORT(sqInt) primitivePerformSyncCall(void);
EXPORT(sqInt) primitiveReadNextCallback(void);
EXPORT(sqInt) primitiveRegisterCallback(void);
EXPORT(sqInt) primitiveTypeByteSize(void);
EXPORT(sqInt) primitiveUnregisterCallback(void);
EXPORT(sqInt) setInterpreter(struct VirtualMachine*anInterpreter);


/*** Variables ***/

static sqInt (*failed)(void);
static sqInt (*fetchPointerofObject)(sqInt index, sqInt oop);
static sqInt (*integerValueOf)(sqInt oop);
static sqInt (*methodReturnInteger)(sqInt integer);
static sqInt (*pop)(sqInt nItems);
static sqInt (*stObjectat)(sqInt array, sqInt index);
static sqInt (*stSizeOf)(sqInt oop);
static sqInt (*stackValue)(sqInt offset);

struct VirtualMachine* interpreterProxy;
static const char *moduleName = "PThreadedPlugin * ThreadedFFI-Plugin-pt.2 (e)";



/*	Note: This is hardcoded so it can be run from Squeak.
	The module name is used for validating a module *after*
	it is loaded to check if it does really contain the module
	we're thinking it contains. This is important! */

	/* InterpreterPlugin>>#getModuleName */
EXPORT(const char*)
getModuleName(void)
{
	return moduleName;
}

EXPORT(sqInt)
initialiseModule(void)
{
	return initializeWorkerThread();
}

	/* PThreadedPlugin>>#primitiveCallbackReturn */
EXPORT(sqInt)
primitiveCallbackReturn(void)
{
    void*  handler;
    sqInt receiver;

	receiver = stackValue(0);
	handler = getHandler(receiver);
	callbackReturn(handler);
	return 0;
}

	/* PThreadedPlugin>>#primitiveDefineFunction */
EXPORT(sqInt)
primitiveDefineFunction(void)
{
    sqInt count;
    void*handler;
    sqInt idx;
    ffi_type** parameters;
    sqInt paramsArray;
    sqInt receiver;
    void*returnType;

	returnType = readAddress(stackValue(0));
	count = stSizeOf(stackValue(1));
	paramsArray = stackValue(1);

	/* The parameters are freed by the primitiveFreeDefinition, if there is an error it is freed by #defineFunction:With:And: */
	receiver = stackValue(2);
	parameters = malloc(count*sizeof(void*));
	for (idx = 0; idx < count; idx += 1) {
		parameters[idx] = (readAddress(stObjectat(paramsArray, idx + 1)));
	}
	if (failed()) {
		return null;
	}
	handler = defineFunctionWithAnd(parameters, count, returnType);
	if (failed()) {
		return null;
	}
	setHandler(receiver, handler);
	if (!(failed())) {
		pop(2);
	}
	return 0;
}

	/* PThreadedPlugin>>#primitiveFillBasicType */
EXPORT(sqInt)
primitiveFillBasicType(void)
{
	fillBasicType(stackValue(0));
	return 0;
}

	/* PThreadedPlugin>>#primitiveFreeDefinition */
EXPORT(sqInt)
primitiveFreeDefinition(void)
{
    void*handler;
    sqInt receiver;

	receiver = stackValue(0);
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
EXPORT(sqInt)
primitiveInitializeCallbacksQueue(void)
{
    int index;

	index = integerValueOf(stackValue(0));
	initCallbackQueue(index);
	if (!(failed())) {
		pop(1);
	}
	return 0;
}

	/* PThreadedPlugin>>#primitivePerformCall */
EXPORT(sqInt)
primitivePerformCall(void)
{
    void*aCif;
    void*aExternalFunction;
    void*parametersAddress;
    void*returnHolderAddress;
    sqInt semaphoreIndex;

	semaphoreIndex = integerValueOf(stackValue(0));
	returnHolderAddress = readAddress(stackValue(1));
	parametersAddress = readAddress(stackValue(2));
	aExternalFunction = getHandler(stackValue(3));
	aCif = getHandler(fetchPointerofObject(1, stackValue(3)));
	if (failed()) {
		return null;
	}
	performCallCifWithIntoUsing(aExternalFunction, aCif, parametersAddress, returnHolderAddress, semaphoreIndex);
	if (failed()) {
		return null;
	}
	if (!(failed())) {
		pop(4);
	}
	return 0;
}

	/* PThreadedPlugin>>#primitivePerformCall */
EXPORT(sqInt)
primitivePerformSyncCall(void)
{
    void*aCif;
    void*aExternalFunction;
    void*parametersAddress;
    void*returnHolderAddress;

	returnHolderAddress = readAddress(stackValue(0));
	parametersAddress = readAddress(stackValue(1));
	aExternalFunction = getHandler(stackValue(2));
	aCif = getHandler(fetchPointerofObject(1, stackValue(2)));
	if (failed()) {
		return null;
	}
	performSyncCallCifWithInto(aExternalFunction, aCif, parametersAddress, returnHolderAddress);
	if (failed()) {
		return null;
	}
	if (!(failed())) {
		pop(3);
	}
	return 0;
}



	/* PThreadedPlugin>>#primitiveReadNextCallback */
EXPORT(sqInt)
primitiveReadNextCallback(void)
{
    CallbackInvocation* address;
    sqInt externalAddress;

	externalAddress = stackValue(0);
	address = getNextCallback();
	writeAddress(externalAddress, address);
	if (!(failed())) {
		pop(1);
	}
	return 0;
}

	/* PThreadedPlugin>>#primitiveRegisterCallback */
EXPORT(sqInt)
primitiveRegisterCallback(void)
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

	receiver = stackValue(0);
	callbackData = fetchPointerofObject(1, receiver);
	paramArray = fetchPointerofObject(2, receiver);
	count = stSizeOf(paramArray);

	/* The parameters are freed by the primitiveFreeDefinition, if there is an error it is freed by #defineCallback:WithParams:Count:ReturnType: */
	callbackDataPtr = NULL;
	parameters = malloc(count*sizeof(void*));
	returnType = getHandler(fetchPointerofObject(3, receiver));
	for (idx = 0; idx < count; idx += 1) {
		parameters[idx] = (getHandler(stObjectat(paramArray, idx + 1)));
	}
	if (failed()) {
		return null;
	}
	handler = defineCallbackWithParamsCountReturnType((&callbackDataPtr), parameters, count, returnType);
	if (failed()) {
		return null;
	}
	setHandler(receiver, handler);
	writeAddress(callbackData, callbackDataPtr);
	return 0;
}

	/* PThreadedPlugin>>#primitiveTypeByteSize */
EXPORT(sqInt)
primitiveTypeByteSize(void)
{
    void* handler;
    sqInt receiver;
    sqInt size;

	receiver = stackValue(0);
	handler = getHandler(receiver);
	size = getTypeByteSize(handler);
	if (!(failed())) {
		methodReturnInteger(size);
	}
	return 0;
}

	/* PThreadedPlugin>>#primitiveUnregisterCallback */
EXPORT(sqInt)
primitiveUnregisterCallback(void)
{
    sqInt callbackData;
    CallbackData*  callbackDataPtr;
    sqInt receiver;

	receiver = stackValue(0);
	callbackData = fetchPointerofObject(1, receiver);
	callbackDataPtr = readAddress(callbackData);
	releaseCallback(callbackDataPtr);
	return 0;
}


/*	Note: This is coded so that it can be run in Squeak. */

	/* InterpreterPlugin>>#setInterpreter: */
EXPORT(sqInt)
setInterpreter(struct VirtualMachine*anInterpreter)
{
    sqInt ok;

	interpreterProxy = anInterpreter;
	ok = ((interpreterProxy->majorVersion()) == (VM_PROXY_MAJOR))
	 && ((interpreterProxy->minorVersion()) >= (VM_PROXY_MINOR));
	if (ok) {
		failed = interpreterProxy->failed;
		fetchPointerofObject = interpreterProxy->fetchPointerofObject;
		integerValueOf = interpreterProxy->integerValueOf;
		methodReturnInteger = interpreterProxy->methodReturnInteger;
		pop = interpreterProxy->pop;
		stObjectat = interpreterProxy->stObjectat;
		stSizeOf = interpreterProxy->stSizeOf;
		stackValue = interpreterProxy->stackValue;
	}
	return ok;
}