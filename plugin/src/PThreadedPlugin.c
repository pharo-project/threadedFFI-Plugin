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

	if(!handler){
		interpreterProxy->primitiveFail();
		return;
	}

	free(((ffi_cif*)handler)->arg_types);
	free(handler);

	setHandler(receiver, 0);
}

Primitive(primitiveInitializeCallbacksQueue){
    int index;

    printf("Initializing Queue\n");

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

/**
 * This primitive initialize a struct type.
 * It assumes that the struct type is an external object.
 * It should have as slots:
 *
 * 1) An External Address (it should be a external object)
 * 2) An array with the members of the struct. Each member should be a valid type.
 * 3) An array with the same size of members that will receive the offsets of the members
 *
 * This primitive will allocate the required structs and fails if it cannot be allocated
 * or the parameters are no good.
 *
 * Also it calculates the offsets of the struct.
 *
 */

PrimitiveWithDepth(primitiveInitializeStructType, 2){
	sqInt receiver;
	sqInt arrayOfMembers;
	sqInt arrayOfOffsets;
	sqInt membersSize;
	ffi_type* structType;
	ffi_type** memberTypes;
	size_t* offsets;

	receiver = interpreterProxy->stackValue(0);
	checkFailed();

	getHandler(receiver);
	checkFailed();

	arrayOfMembers = interpreterProxy->fetchPointerofObject(1, receiver);
	checkFailed();

	arrayOfOffsets = interpreterProxy->fetchPointerofObject(2, receiver);
	checkFailed();

	//Validating that they are arrays.
	checkIsArray(arrayOfMembers);
	checkIsArray(arrayOfOffsets);

	membersSize = interpreterProxy->stSizeOf(arrayOfMembers);
	if(membersSize < 1){
		interpreterProxy->primitiveFail();
		return;
	}

	if(membersSize != interpreterProxy->stSizeOf(arrayOfOffsets)){
		interpreterProxy->primitiveFail();
		return;
	}

	//Validating that the members are of valid size
	for(int i=0; i < membersSize; i++){
		checkIsPointerSize(interpreterProxy->stObjectat(arrayOfMembers, i + 1), 1);
	}

	// Allocating the structure type
	structType = malloc(sizeof(ffi_type));
	if(!structType){
		interpreterProxy->primitiveFail();
		return;
	}

	memberTypes = malloc(sizeof(ffi_type*) * (membersSize+1));
	if(!memberTypes){
		free(structType);
		interpreterProxy->primitiveFail();
		return;
	}

	offsets = malloc(sizeof(size_t) * (membersSize));
	if(!offsets){
		free(memberTypes);
		free(structType);
		interpreterProxy->primitiveFail();
		return;
	}

	//The members list is ended by a NULL
	memberTypes[membersSize] = NULL;

	structType->alignment = 0;
	structType->size = 0;
	structType->type = FFI_TYPE_STRUCT;
	structType->elements = memberTypes;

	for(int i=0; i < membersSize; i++){
		memberTypes[i] = getHandler(interpreterProxy->stObjectat(arrayOfMembers, i + 1));
	}

	setHandler(receiver, structType);
	if(interpreterProxy->failed()){
		free(memberTypes);
		free(structType);
		free(offsets);
		return;
	}

	if(ffi_get_struct_offsets(FFI_DEFAULT_ABI, structType, offsets)!=FFI_OK){
		free(memberTypes);
		free(structType);
		free(offsets);
		interpreterProxy->primitiveFail();
		return;
	}

	for(int i=0; i < membersSize; i++){
		interpreterProxy->stObjectatput(arrayOfOffsets, i+1, interpreterProxy->integerObjectOf(offsets[i]));
	}

	free(offsets);
}

/**
 * This primitive frees the struct type ffi_type memory and the array used to hold the members.
 */

PrimitiveWithDepth(primitiveFreeStruct, 1){
	sqInt receiver;
	ffi_type* structType;

	receiver = interpreterProxy->stackValue(0);
	checkFailed();

	structType = (ffi_type*)getHandler(receiver);
	checkFailed();

	if(!structType){
		interpreterProxy->primitiveFail();
		return;
	}

	free(structType->elements);
	free(structType);

	setHandler(receiver, NULL);
}

/**
 * This primitive returns the size of the struct type.
 */
PrimitiveWithDepth(primitiveStructByteSize, 1){
	sqInt receiver;
	ffi_type* structType;

	receiver = interpreterProxy->stackValue(0);
	checkFailed();

	structType = (ffi_type*)getHandler(receiver);
	checkFailed();

	if(!structType){
		interpreterProxy->primitiveFail();
		return;
	}

	interpreterProxy->pop(1);
	interpreterProxy->pushInteger(structType->size);
}

/**
 * This primitive copy the memory from an object to the other.
 * The parameters could be ByteArrays or ExternalAddress.
 *
 * It receives three parameters:
 *
 * - A From
 * - A To
 * - A Size
 */
PrimitiveWithDepth(primitiveCopyFromTo, 1){
	sqInt from;
	sqInt to;
	sqInt size;

	void* fromAddress;
	void* toAddress;

	size = interpreterProxy->stackIntegerValue(0);
	checkFailed();

	to = interpreterProxy->stackObjectValue(1);
	checkFailed();

	from = interpreterProxy->stackObjectValue(2);
	checkFailed();


	fromAddress = getAddressFromExternalAddressOrByteArray(from);
	checkFailed();

	toAddress = getAddressFromExternalAddressOrByteArray(to);
	checkFailed();

	memcpy(toAddress, fromAddress, size);

	interpreterProxy->pop(3);
}

sqInt setInterpreter(struct VirtualMachine* anInterpreter)
{
    sqInt ok;

	interpreterProxy = anInterpreter;
	ok = ((interpreterProxy->majorVersion()) == (VM_PROXY_MAJOR))
	 && ((interpreterProxy->minorVersion()) >= (VM_PROXY_MINOR));

	return ok;
}
