#include "PThreadedPlugin.h"
#include "worker.h"

/* primitiveRegisterWorker
 *   adds a worker and answers its handle
 *   arguments:
 *   - name <String>
 */
PrimitiveWithDepth(primitiveRegisterWorker, 2) {
    int semaphoreIndex = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0));
    checkFailed();
    char *name = readString(interpreterProxy->stackValue(1));
    checkFailed();

    Worker *worker = worker_new(name, semaphoreIndex);
    worker_register(worker);

    sqInt workerHandle = newExternalAddress(worker);
    checkFailed();

    primitiveEndReturn(workerHandle);
}

/* primitiveUnregisterWorker
 *   removes a worker
 *   arguments:
 *   - workerHandle <ExternalAddress>
 */
PrimitiveWithDepth(primitiveUnregisterWorker, 2) {
    sqInt workerHandle = interpreterProxy->stackValue(0);
    Worker *worker = (Worker *)readAddress(workerHandle);
    checkFailed();

    if(worker) {
        worker_unregister(worker);
        checkFailed();
        worker_release(worker);
        writeAddress(workerHandle, 0);
        checkFailed();
    } else {
        interpreterProxy->primitiveFail();
    }

    primitiveEnd();
}

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

PrimitiveWithDepth(primitiveInitializeWorkerCallbackQueue, 1) {
	sqInt index;

    Worker *worker = (Worker *)readAddress(interpreterProxy->stackValue(1));
    checkFailed();

    index = interpreterProxy->integerValueOf(interpreterProxy->stackValue(0));
    worker_set_callback_semaphore_index(worker, index);
    checkFailed();

    primitiveEnd();
}

/* primitivePerformWorkerCall
 *  arguments:
 *  5 - externalFunction        <ExternalAddress>
 *  4 - arguments               <ExternalAddress>
 *  3 - returnHolder            <ExternalAddress>
 *  2 - semaphoreIndex          <Integer>
 *  1 - workerHandle            <ExternalAddress>
 *  0 - extra                   <Array> (or nil)
 */
// This is just because arguments are placed in order in stack, then they are inverse. And is confusing ;)
#define PARAM_EXTERNAL_FUNCTION     5
#define PARAM_ARGUMENTS             4
#define PARAM_RETURN_HOLDER         3
#define PARAM_SEMAPHORE_INDEX       2
#define PARAM_WORKER_HANDLE         1
#define PARAM_QUEUE                 0
PrimitiveWithDepth(primitivePerformWorkerCall, 2) {
    void *cif;
    void *externalFunction;
    void *parameters;
    void *returnHolder;
    sqInt semaphoreIndex;
    WorkerTask *task;
    Worker *worker;
    sqInt queue;

    semaphoreIndex = interpreterProxy->integerValueOf(interpreterProxy->stackValue(PARAM_SEMAPHORE_INDEX));
    checkFailed();

    returnHolder = readAddress(interpreterProxy->stackValue(PARAM_RETURN_HOLDER));
    checkFailed();

    parameters = readAddress(interpreterProxy->stackValue(PARAM_ARGUMENTS));
    checkFailed();

    externalFunction = getHandler(interpreterProxy->stackValue(PARAM_EXTERNAL_FUNCTION));
    checkFailed();

    cif = getHandler(interpreterProxy->fetchPointerofObject(1, interpreterProxy->stackValue(PARAM_EXTERNAL_FUNCTION)));
    checkFailed();

    worker = (Worker *)readAddress(interpreterProxy->stackValue(PARAM_WORKER_HANDLE));
    checkFailed();

    task = worker_task_new(externalFunction, cif, parameters, returnHolder, semaphoreIndex);
    checkFailed();

    queue = interpreterProxy->stackValue(PARAM_QUEUE);
    if(!(queue == interpreterProxy->nilObject())) {
        checkIsArray(queue);
        check(arrayObjectSize(queue) == 2);

        if(arrayObjectAt(queue, 0) == interpreterProxy->trueObject()) {
			#ifdef __APPLE__
				worker_task_set_main_queue(task);
			#else
				interpreterProxy->primitiveFail();
				return;
			#endif
        } else {
            worker_task_set_queue(task, readAddress(arrayObjectAt(queue, 1)));
            checkFailed();
        }
    }

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
