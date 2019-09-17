#include "setjmp.h"
#include "PThreadedPlugin.h"

#include "vmCallback.h"

/*
 * Define sigsetjmp and siglongjmp to be the most minimal setjmp/longjmp available on the platform.
 * Note: on windows 64 via mingw-w64, the 2nd argument NULL to _setjmp prevents stack unwinding
 */
#undef sigsetjmp
#undef siglongjmp
#if _MSC_VER
# define sigsetjmp(jb,ssmf) _setjmp(jb)
# define siglongjmp(jb,v) longjmp(jb,v)
#elif _WIN64 && __GNUC__
# define sigsetjmp(jb,ssmf) _setjmp(jb,NULL)
# define siglongjmp(jb,v) longjmp(jb,v)
#elif _WIN32
# define sigsetjmp(jb,ssmf) setjmp(jb)
# define siglongjmp(jb,v) longjmp(jb,v)
#else
# define sigsetjmp(jb,ssmf) _setjmp(jb)
# define siglongjmp(jb,v) _longjmp(jb,v)
#endif

void sameThreadCallbackEnter(struct _Runner* runner, struct _CallbackInvocation* callback);
void sameThreadCallbackExit(struct _Runner* runner, struct _CallbackInvocation* callback);

static Runner sameThreadRunner = {
	sameThreadCallbackEnter,
	sameThreadCallbackExit,
    NULL
};

/* primitivePerformWorkerCall
 *
 *  receiver: A worker <TFWorker>
 *
 *  arguments:
 *  3 - externalFunction        <ExternalAddress>
 *  2 - arguments               <ExternalAddress>
 *  1 - returnHolder            <ExternalAddress>
 *  0 - SemaphoreIndex 			<Integer>
 */
// This is just because arguments are placed in order in stack, then they are inverse. And is confusing ;)
#define PARAM_EXTERNAL_FUNCTION     3
#define PARAM_ARGUMENTS             2
#define PARAM_RETURN_HOLDER         1
#define PARAM_SEMAPHORE_INDEX       0

PrimitiveWithDepth(primitiveSameThreadCallout, 2) {
    void *cif;
    void *externalFunction;
    void *parameters;
    void *returnHolder;
    sqInt receiver;
    sqInt semaphoreIndex;

    returnHolder = readAddress(interpreterProxy->stackValue(PARAM_RETURN_HOLDER));
    checkFailed();

    parameters = readAddress(interpreterProxy->stackValue(PARAM_ARGUMENTS));
    checkFailed();

    externalFunction = getHandler(interpreterProxy->stackValue(PARAM_EXTERNAL_FUNCTION));
    checkFailed();

    //Getting the function CIF of LibFFI
    cif = getHandler(interpreterProxy->fetchPointerofObject(1, interpreterProxy->stackValue(PARAM_EXTERNAL_FUNCTION)));
    checkFailed();

    //Getting the function CIF of LibFFI
    cif = getHandler(interpreterProxy->fetchPointerofObject(1, interpreterProxy->stackValue(PARAM_EXTERNAL_FUNCTION)));
    checkFailed();

    semaphoreIndex = interpreterProxy->stackIntegerValue(PARAM_SEMAPHORE_INDEX);
    checkFailed();

    receiver = getReceiver();
    checkFailed();

    ffi_call(cif,
    		externalFunction,
            returnHolder,
			parameters);

    interpreterProxy->signalSemaphoreWithIndex(semaphoreIndex);
    checkFailed();

    primitiveEnd();
}


Primitive(primitiveGetSameThreadRunnerAddress) {

	sqInt externalAddress;

	externalAddress = interpreterProxy->instantiateClassindexableSize(interpreterProxy->classExternalAddress(), sizeof(void*));
    checkFailed();

    writeAddress(externalAddress, &sameThreadRunner);
    checkFailed();

    interpreterProxy->ptDisableCogIt(primitiveSameThreadCallout);

    primitiveEndReturn(externalAddress);
}

void sameThreadCallbackEnter(struct _Runner* runner, struct _CallbackInvocation* callback){

	VMCallbackContext *vmcc;
	sqInt flags;

//	if ((flags = interpreterProxy->ownVM(0)) < 0) {
//		fprintf(stderr,"Warning; callback failed to own the VM\n");
//		return;
//	}

	vmcc = malloc(sizeof(VMCallbackContext));

	callback->payload = vmcc;

	if ((!sigsetjmp(vmcc->trampoline, 0))) {
		//Used to mark that is a fake callback!
		vmcc->thunkp = NULL;
		vmcc->stackp = NULL;
		vmcc->intregargsp = NULL;
		vmcc->floatregargsp = NULL;
		interpreterProxy->ptEnterInterpreterFromCallback(vmcc);
		fprintf(stderr,"Warning; callback failed to invoke\n");
//		interpreterProxy->disownVM(flags);
		return;
	}

	free(vmcc);

//	interpreterProxy->disownVM(flags);
}

void sameThreadCallbackExit(struct _Runner* runner, struct _CallbackInvocation* callback){

	VMCallbackContext *vmcc;
	vmcc = (VMCallbackContext*)callback->payload;

	interpreterProxy->ptExitInterpreterToCallback(vmcc);
}
