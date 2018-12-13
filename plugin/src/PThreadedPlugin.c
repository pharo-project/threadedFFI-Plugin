#include "PThreadedPlugin.h"
#include "worker.h"

/*** Variables ***/

struct VirtualMachine* interpreterProxy;
static const char *moduleName = "PThreadedPlugin * ThreadedFFI-Plugin-PGE.1 (e)";

const char * getModuleName(void){
	return moduleName;
}

sqInt initialiseModule(void){
    return 1;
}

/* primitiveRegisterWorker
 *   adds a worker and answers its handle
 *   arguments:
 *   - name <String>
 */
PrimitiveWithDepth(primitiveRegisterWorker, 2) {
    char *name = readString(interpreterProxy->stackValue(0));
    checkFailed();
    
    Worker *worker = worker_new(name);
    worker_register(worker);
    
    sqInt workerHandle = newExternalAddress();
    checkFailed();
    
    writeAddress(workerHandle, worker);
    checkFailed();
    
    primitiveEndReturn(workerHandle);
}

/* primitiveUnregisterWorker
 *   removes a worker
 *   arguments:
 *   - workerHandle <ExternalAddress>
 */
/*
PrimitiveWithDepth(primitiveUnregisterWorker, 2) {
    sqInt workerHandle = interpreterProxy->stackValue(0);
    Worker *worker = (Worker *)readAddress(workerHandle);
    checkFailed();
    
    worker_unregister(worker);
    worker_release(worker);
    
    writeAddress(workerHandle, 0);
    checkFailed();
    
    primitiveEnd();
}
*/

/* primitiveWorkerCallbackReturn
 *   returns from a callback
 *   arguments:
 *   - workerHandle <ExternalAddress>
 */
PrimitiveWithDepth(primitiveWorkerCallbackReturn, 1) {
    void *handler;
    Worker *worker;
    sqInt receiver;

    receiver = getReceiver();
    checkFailed();

    handler = getHandler(receiver);
    checkFailed();

    worker = (Worker *)readAddress(interpreterProxy->stackValue(0));
    checkFailed();

	worker_callback_return(worker, handler);

    primitiveEnd();
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

PrimitiveWithDepth(primitiveInitializeWorkerCallbackQueue, 1) {
	sqInt index;
    
    Worker *worker = (Worker *)readAddress(interpreterProxy->stackValue(1));
    checkFailed();
    
    index = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0));
    worker_set_callback_semaphore_index(worker, index);
    checkFailed();
    
    primitiveEnd();
}

/* prepareWorkerTaskFromPrimitiveParameters
 *  recognises a call with parameters (externalFunction, parametersAddress, returnHolderAddress, semaphoreIndex)
 *  and creates a WorkerTask with it.
 */
static WorkerTask *prepareWorkerTaskFromPrimitiveParameters() {
    void *cif;
    void *externalFunction;
    void *parameters;
    void *returnHolder;
    sqInt semaphoreIndex;
    
    semaphoreIndex = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0));
    checkFailedReturn(NULL);
    
    returnHolder = readAddress(interpreterProxy->stackValue(1));
    checkFailedReturn(NULL);

    parameters = readAddress(interpreterProxy->stackValue(2));
    checkFailedReturn(NULL);

    externalFunction = getHandler(interpreterProxy->stackValue(3));
    checkFailedReturn(NULL);

    cif = getHandler(interpreterProxy->fetchPointerofObject(1, interpreterProxy->stackValue(3)));
    checkFailedReturn(NULL);

    return worker_task_new(externalFunction, cif, parameters, returnHolder, semaphoreIndex);
}

/* primitivePerformWorkerCall
 *  arguments:
 *  - externalFunction        <ExternalAddress>
 *  - arguments               <ExternalAddress>
 *  - returnHolder            <ExternalAddress>
 *  - semaphoreIndex          <Integer>
 */
PrimitiveWithDepth(primitivePerformWorkerCall, 2) {

    sqInt receiver = getReceiver();
    checkFailed();

    // handler is in third position. This is kind of bad so maybe pass it by parameter
    Worker *worker = (Worker *)readAddress(getAttributeOf(receiver, 3));
    checkFailed();

    WorkerTask *task = prepareWorkerTaskFromPrimitiveParameters();
    checkFailed();

    worker_dispatch_callout(worker, task);
    checkFailed();

    primitiveEnd();
}

/* primitiveReadNextWorkerCallback
 *  answers next pending callback
 *  arguments:
 *  - workerHandle <ExternalAddress>
 */
PrimitiveWithDepth(primitiveReadNextWorkerCallback, 1){
    Worker *worker;
    CallbackInvocation *address;
    
    worker = (Worker *)readAddress(interpreterProxy->stackValue(0));
    checkFailed();

    address = worker_next_pending_callback(worker);
    checkFailed();
   
    sqInt externalAddress;
    if(address) {
        externalAddress = interpreterProxy->instantiateClassindexableSize(interpreterProxy->classExternalAddress(), sizeof(void*));
        checkFailed();

        writeAddress(externalAddress, address);
        checkFailed();
    } else {
        externalAddress = interpreterProxy->nilObject();
    }
    
    primitiveEndReturn(externalAddress);
}

PrimitiveWithDepth(primitiveRegisterWorkerCallback, 3){
    sqInt callbackHandle;
    Callback *callback;
    sqInt count;
    void *handler;
    sqInt idx;
    sqInt paramArray;
    ffi_type **parameters;
    sqInt receiver;
    ffi_type *returnType;
    
    receiver = getReceiver();
    checkFailed();
    
    Worker *worker = (Worker *)readAddress(interpreterProxy->stackValue(0));
    checkFailed();
    
    callbackHandle = getAttributeOf(receiver, 1);
    checkFailed();
    
    paramArray = getAttributeOf(receiver, 2);
    checkFailed();
    
    count = interpreterProxy->stSizeOf(paramArray);
    checkFailed();
    
    /*
       The parameters are freed by the primitiveFreeDefinition, if there is an error it is freed
       by #defineCallback:WithParams:Count:ReturnType:
     */
    parameters = malloc(count*sizeof(void*));
    returnType = getHandler(getAttributeOf(receiver, 3));
    for (idx = 0; idx < count; idx += 1) {
        parameters[idx] = (getHandler(interpreterProxy->stObjectat(paramArray, idx + 1)));
    }
    checkFailed();
    
    callback = callback_new(worker, parameters, count, returnType);
    checkFailed();
    
    setHandler(receiver, callback->functionAddress);
    checkFailed();
    
    writeAddress(callbackHandle, callback);
    checkFailed();
    
    primitiveEnd();
}


PrimitiveWithDepth(primitiveTypeByteSize, 1){
    void* handler;
    sqInt receiver;
    sqInt size;

	receiver = getReceiver();

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

    primitiveEndReturnInteger(oop + BaseHeaderSize);
}

/*
 * This primitive returns the object in an oop passed as integer.
 */
Primitive(primitiveGetObjectFromAddress){
	sqInt oop;

	oop = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0)) - BaseHeaderSize;
	checkFailed();

    primitiveEndReturn(oop);
}

/* primitiveUnregisterWorkerCallback
 *  unregisters callback (taking a handle as parameter)
 *  arguments:
 *  - workerHandle      <ExternalAddress>
 *  - callbackHandle    <ExternalAddress>
 */
PrimitiveWithDepth(primitiveUnregisterWorkerCallback, 1){
    Callback *callback;
    sqInt receiver;

    // In fact, I do not need a worker now.
    // I just keeping it for posible future usage
    
    callback = (Callback *)readAddress(interpreterProxy->stackValue(0));
    checkFailed();
    
    callback_release(callback);
    
    primitiveEnd();
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

	receiver = getReceiver();
	checkFailed();

    // Verify we have a valid handle
	getHandler(receiver);
	checkFailed();

	arrayOfMembers = getAttributeOf(receiver, 1);
	checkFailed();

	arrayOfOffsets = getAttributeOf(receiver, 2);
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
    
    //primitiveEnd(); // No need to call it
}

/**
 * This primitive frees the struct type ffi_type memory and the array used to hold the members.
 */
PrimitiveWithDepth(primitiveFreeStruct, 1){
	sqInt receiver;
	ffi_type* structType;

	receiver = getReceiver();
	checkFailed();

	structType = (ffi_type *)getHandler(receiver);
	checkFailed();

	if(!structType){
		interpreterProxy->primitiveFail();
		return;
	}

	free(structType->elements);
	free(structType);

	setHandler(receiver, NULL);

    //primitiveEnd(); //No need to call it
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

    primitiveEndReturnInteger(structType->size);
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

	primitiveEnd();
}

sqInt setInterpreter(struct VirtualMachine* anInterpreter)
{
    sqInt ok;

	interpreterProxy = anInterpreter;
	ok = ((interpreterProxy->majorVersion()) == (VM_PROXY_MAJOR))
	 && ((interpreterProxy->minorVersion()) >= (VM_PROXY_MINOR));

	return ok;
}
