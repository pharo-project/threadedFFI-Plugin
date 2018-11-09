#include "PThreadedPlugin.h"

/*** Variables ***/

struct VirtualMachine* interpreterProxy;
static const char *moduleName = "PThreadedPlugin * ThreadedFFI-Plugin-pt.2 (e)";

/*
 * The primitives should be defined with a depth parameter.
 * For this, the following macros are generated.
 *
 * Primitive macro generates with 0, because it is the normal value for depth.
 * PrimitiveWithDepth receives a parameters for the depth.
 *
 * What is depth?
 *
 * Initially when the VM executes a primitive it does not handle the forwarding
 * of the parameters. It sends the parameters as they are.
 * A primitive should validate the parameters sent to it.
 * If they are not valid (or they are a forwarder, and they need to be used) it should fail.
 *
 * The VM will handle the resolution of the forwarders and recall the primitive.
 * If the depth is -1, the VM will not do nothing and just fail the call.
 * If the depth is >=0, the VM will resolve the forwarders and then recall the primitive.
 *
 * The depth, is the levels of accessors used in the primitive.
 *
 * If the primitive only uses the objects received by parameter the depth is 0,
 * if it uses one of the objects refereced by the parameters the depth is 1, and so on.
 *
 * Example
 * =======
 *
 * [ p ] --> [ a ] -> [ x ]
 * 		 --> [ b ]
 * 		 \-> [ c ] -> [ y ]
 *
 *
 * If we only require to use the object p (that is a parameter to the primitive in the stack),
 * the depth is 0, if we want to use the object a, b or c (that are referenciated by p) the depth
 * should be 1. In the case of wanting to use x or y, depth should be 2.
 *
 */

#define Primitive(functionName) signed char functionName ##AccessorDepth = 0; \
	sqInt functionName (void)

#define PrimitiveWithDepth(functionName, N) signed char functionName ##AccessorDepth = N; \
	sqInt functionName (void)

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
	handler = getHandler(receiver);
	callbackReturn(handler);
	return 0;
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

Primitive(primitiveFillBasicType){
	fillBasicType(interpreterProxy->stackValue(0));
	return 0;
}

PrimitiveWithDepth(primitiveFreeDefinition, 1){
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

Primitive(primitiveInitializeCallbacksQueue){
    int index;

	index = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0));
	initCallbackQueue(index);
	if (!(interpreterProxy->failed())) {
		interpreterProxy->pop(1);
	}
	return 0;
}

PrimitiveWithDepth(primitivePerformCall, 2){
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

PrimitiveWithDepth(primitivePerformSyncCall, 2){
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



PrimitiveWithDepth(primitiveReadNextCallback, 1){
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
		return -1;
	}
	handler = defineCallbackWithParamsCountReturnType((&callbackDataPtr), parameters, count, returnType);
	if (interpreterProxy->failed()) {
		return -1;
	}
	setHandler(receiver, handler);
	writeAddress(callbackData, callbackDataPtr);
	return 0;
}

PrimitiveWithDepth(primitiveTypeByteSize, 1){
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

/*
 * This primitive returns the address of an image object.
 * It fails if the object is not pinned.
 *
 * Receives an OOP as parameter and returns an SmallInteger
 */
Primitive(primitiveGetAddressOfOOP){
	sqInt oop;

	oop = interpreterProxy->stackValue(0);

	if(!interpreterProxy->isPinned(oop)){
//		interpreterProxy->primitiveFailFor(PrimErrBadReceiver);
		interpreterProxy->primitiveFail();
		return -1;
	}

	interpreterProxy->pop(2);
	interpreterProxy->pushInteger(oop + BaseHeaderSize);
	return 0;
}

/*
 * This primitive returns the object in an oop passed as integer.
 */

Primitive(primitiveGetObjectFromAddress){
	sqInt oop;

	oop = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0)) - BaseHeaderSize;

	interpreterProxy->popthenPush(2, oop);
	return 0;
}


PrimitiveWithDepth(primitiveUnregisterCallback, 1){
    sqInt callbackData;
    CallbackData*  callbackDataPtr;
    sqInt receiver;

	receiver = interpreterProxy->stackValue(0);
	callbackData = interpreterProxy->fetchPointerofObject(1, receiver);
	callbackDataPtr = readAddress(callbackData);
	releaseCallback(callbackDataPtr);
	return 0;
}

sqInt setInterpreter(struct VirtualMachine* anInterpreter)
{
    sqInt ok;

	interpreterProxy = anInterpreter;
	ok = ((interpreterProxy->majorVersion()) == (VM_PROXY_MAJOR))
	 && ((interpreterProxy->minorVersion()) >= (VM_PROXY_MINOR));

	return ok;
}
