#include "PThreadedPlugin.h"

/*** Variables ***/

struct VirtualMachine* interpreterProxy;
static const char *moduleName = "PThreadedPlugin * ThreadedFFI-Plugin-pt.2 (e)";

const char * getModuleName(void){
	return moduleName;
}

sqInt initialiseModule(void){
	return initializeWorkerThread();
}

PrimitiveWithDepth(primitiveCallbackReturn, 1){
    void*  handler;
    sqInt receiver;

    receiver = interpreterProxy->stackValue(0);
    checkFailed();

    handler = getHandler(receiver);
    checkFailed();

	callbackReturn(handler);
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

	if (interpreterProxy->failed()) {
		return;
	}

	handler = defineFunctionWithAnd(parameters, count, returnType);
	if (interpreterProxy->failed()) {
		return;
	}

	setHandler(receiver, handler);
	checkFailed();

	interpreterProxy->pop(2);
}

Primitive(primitiveFillBasicType){
	fillBasicType(interpreterProxy->stackValue(0));
}

PrimitiveWithDepth(primitiveFreeDefinition, 1){
    void*handler;
    sqInt receiver;

	receiver = interpreterProxy->stackValue(0);
	checkFailed();

	handler = getHandler(receiver);
	checkFailed();

	free(((ffi_cif*)handler)->arg_types);
	free(handler);

	setHandler(receiver, 0);
}

Primitive(primitiveInitializeCallbacksQueue){
    int index;

	index = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0));
	initCallbackQueue(index);
	checkFailed();

	interpreterProxy->pop(1);
}

PrimitiveWithDepth(primitivePerformCall, 2){
    void*aCif;
    void*aExternalFunction;
    void*parametersAddress;
    void*returnHolderAddress;
    sqInt semaphoreIndex;

	semaphoreIndex = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0));
	checkFailed();

	returnHolderAddress = readAddress(interpreterProxy->stackValue(1));
	checkFailed();

	parametersAddress = readAddress(interpreterProxy->stackValue(2));
	checkFailed();

	aExternalFunction = getHandler(interpreterProxy->stackValue(3));
	checkFailed();

	aCif = getHandler(interpreterProxy->fetchPointerofObject(1, interpreterProxy->stackValue(3)));
	checkFailed();

	performCallCifWithIntoUsing(aExternalFunction, aCif, parametersAddress, returnHolderAddress, semaphoreIndex);
	checkFailed();

	interpreterProxy->pop(4);
}

PrimitiveWithDepth(primitivePerformSyncCall, 2){
    void*aCif;
    void*aExternalFunction;
    void*parametersAddress;
    void*returnHolderAddress;

	returnHolderAddress = readAddress(interpreterProxy->stackValue(0));
	checkFailed();

	parametersAddress = readAddress(interpreterProxy->stackValue(1));
	checkFailed();

	aExternalFunction = getHandler(interpreterProxy->stackValue(2));
	checkFailed();

	aCif = getHandler(interpreterProxy->fetchPointerofObject(1, interpreterProxy->stackValue(2)));
	checkFailed();

	performSyncCallCifWithInto(aExternalFunction, aCif, parametersAddress, returnHolderAddress);
	checkFailed();

	interpreterProxy->pop(3);
}



PrimitiveWithDepth(primitiveReadNextCallback, 1){
    CallbackInvocation* address;
    sqInt externalAddress;

	externalAddress = interpreterProxy->stackValue(0);
	checkFailed();

	address = getNextCallback();
	checkFailed();

	writeAddress(externalAddress, address);
	checkFailed();

	interpreterProxy->pop(1);
}

PrimitiveWithDepth(primitiveRegisterCallback, 3){
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
	checkFailed();

	callbackData = interpreterProxy->fetchPointerofObject(1, receiver);
	checkFailed();

	paramArray = interpreterProxy->fetchPointerofObject(2, receiver);
	checkFailed();

	count = interpreterProxy->stSizeOf(paramArray);
	checkFailed();

	/* The parameters are freed by the primitiveFreeDefinition, if there is an error it is freed by #defineCallback:WithParams:Count:ReturnType: */
	callbackDataPtr = NULL;
	parameters = malloc(count*sizeof(void*));
	returnType = getHandler(interpreterProxy->fetchPointerofObject(3, receiver));
	for (idx = 0; idx < count; idx += 1) {
		parameters[idx] = (getHandler(interpreterProxy->stObjectat(paramArray, idx + 1)));
	}
	checkFailed();

	handler = defineCallbackWithParamsCountReturnType((&callbackDataPtr), parameters, count, returnType);
	checkFailed();

	setHandler(receiver, handler);
	checkFailed();

	writeAddress(callbackData, callbackDataPtr);
	checkFailed();
}

PrimitiveWithDepth(primitiveTypeByteSize, 1){
    void* handler;
    sqInt receiver;
    sqInt size;

	receiver = interpreterProxy->stackValue(0);

	handler = getHandler(receiver);
	checkFailed();

	size = getTypeByteSize(handler);
	checkFailed();

	interpreterProxy->methodReturnInteger(size);
}

/*
 * This primitive returns the address of an image object.
 * It fails if the object is not pinned.
 *
 * Receives an OOP as parameter and returns an SmallInteger
 */
Primitive(primitiveGetAddressOfOOP){
	sqInt oop;

	oop = interpreterProxy->stackValue(0);
	checkFailed();

	if(!interpreterProxy->isPinned(oop)){
		interpreterProxy->primitiveFail();
		return;
	}

	interpreterProxy->pop(2);
	checkFailed();

	interpreterProxy->pushInteger(oop + BaseHeaderSize);
}

/*
 * This primitive returns the object in an oop passed as integer.
 */

Primitive(primitiveGetObjectFromAddress){
	sqInt oop;

	oop = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0)) - BaseHeaderSize;
	checkFailed();

	interpreterProxy->popthenPush(2, oop);
}


PrimitiveWithDepth(primitiveUnregisterCallback, 1){
    sqInt callbackData;
    CallbackData*  callbackDataPtr;
    sqInt receiver;

	receiver = interpreterProxy->stackValue(0);
	checkFailed();

	callbackData = interpreterProxy->fetchPointerofObject(1, receiver);
	checkFailed();

	callbackDataPtr = readAddress(callbackData);
	checkFailed();

	releaseCallback(callbackDataPtr);
}

sqInt setInterpreter(struct VirtualMachine* anInterpreter)
{
    sqInt ok;

	interpreterProxy = anInterpreter;
	ok = ((interpreterProxy->majorVersion()) == (VM_PROXY_MAJOR))
	 && ((interpreterProxy->minorVersion()) >= (VM_PROXY_MINOR));

	return ok;
}
