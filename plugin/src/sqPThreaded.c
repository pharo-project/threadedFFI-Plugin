#include "PThreadedPlugin.h"

extern struct VirtualMachine* interpreterProxy;

static SemaphoreWrapper pendingCallbacks_semaphore;
static CallbackInvocation* pendingCallbacks[MAX_PENDING_CALLBACKS];
static int firstPendingCallback = 0;
static int nextPendingCallback = 0;
static int initialized = 0;
static int pendingCallbackSemaphoreIndex;


void initCallbackQueue(int semaphore_index){
	
	pendingCallbackSemaphoreIndex = semaphore_index;
	
	if(initialized)
		return;
	
	pendingCallbacks_semaphore = semaphore_create(1);
    if(!isValidSemaphore(pendingCallbacks_semaphore)){
		interpreterProxy->primitiveFailFor(1);
		perror("initCallbackQueue");
		return;        
    }
    
    
	for(int i = 0; i < MAX_PENDING_CALLBACKS; i++){
		pendingCallbacks[i] = NULL;
	}
	
	initialized = 1;
}

CallbackInvocation* getNextCallback(){
	CallbackInvocation* ptr;
	
	int returncode;
	
    returncode = semaphore_wait(pendingCallbacks_semaphore);
	
	if(returncode == -1){
		interpreterProxy->primitiveFailFor(1);
		perror("getNextCallback");
		return NULL;
	}
	
	if(firstPendingCallback == nextPendingCallback){
		ptr = NULL;
	}else{
		ptr = pendingCallbacks[firstPendingCallback];
		pendingCallbacks[firstPendingCallback] = NULL;

		firstPendingCallback++;
		if(firstPendingCallback == MAX_PENDING_CALLBACKS)
			firstPendingCallback = 0;
	}
	
    semaphore_signal(pendingCallbacks_semaphore);

    return ptr;
}

void addPendingCallback(CallbackInvocation* aCallbackInvocation){
	int returncode;
	
    returncode = semaphore_wait(pendingCallbacks_semaphore);
	
	if(returncode == -1){
		interpreterProxy->primitiveFailFor(1);
		perror("addPendingCallback");
		return;
	}
      
	
	pendingCallbacks[nextPendingCallback] = aCallbackInvocation;
	
	nextPendingCallback ++;
	if(nextPendingCallback == MAX_PENDING_CALLBACKS)
		nextPendingCallback = 0;
	
    semaphore_signal(pendingCallbacks_semaphore);
	
	interpreterProxy->signalSemaphoreWithIndex(pendingCallbackSemaphoreIndex);
}

void* readAddress(sqInt anExternalAddress){
	return (*(void**)interpreterProxy->firstIndexableField(anExternalAddress));	
}

void writeAddress(sqInt anExternalAddress, void* value){
	*((void**)interpreterProxy->firstIndexableField(anExternalAddress)) = value;
}

int getTypeByteSize(void* aType){
	return ((ffi_type*) aType)->size;
}

void* getHandler(sqInt anExternalObject){	
	return readAddress(interpreterProxy->fetchPointerofObject(0, anExternalObject));
}

void setHandler(sqInt anExternalObject, void* value){
	writeAddress(interpreterProxy->fetchPointerofObject(0, anExternalObject), value);
}

void fillBasicType(sqInt aOop){
	void* address;
	int typeCode;
	
	typeCode = interpreterProxy->fetchIntegerofObject(2, aOop);
	
	/* 
			"Platform independent types"
			VOID := self newTypeName: #void code: 1.
		 	FLOAT := self newTypeName: #float code: 2.
		 	DOUBLE := self newTypeName: #double code: 3.

			UINT8 := self newIntTypeName: #uint8 code: 4 signed: false.
			UINT16 := self newIntTypeName: #uint16 code: 5 signed: false.
			UINT32 := self newIntTypeName: #uint32 code: 6 signed: false.
			UINT64 := self newIntTypeName: #uint64 code: 7 signed: false.
			
			SINT8 := self newIntTypeName: #sint8 code: 8 signed: true.
			SINT16 := self newIntTypeName: #sint16 code: 9 signed: true.
			SINT32 := self newIntTypeName: #sint32 code: 10 signed: true.
			SINT64 := self newIntTypeName: #sint64 code: 11 signed: true.

			"Aliased types, these depends of the architecture"

			POINTER := self newTypeName: #pointer code: 12.

			UCHAR := self newIntTypeName: #uchar code: 13 signed: false.
			SCHAR := self newIntTypeName: #schar code: 14 signed: true.
			
			USHORT := self newIntTypeName: #ushort code: 15 signed: false.
			SSHORT := self newIntTypeName: #sshort code: 16 signed: true.

			UINT := self newIntTypeName: #uint code: 17 signed: false.
			SINT := self newIntTypeName: #sint code: 18 signed: true.

			ULONG := self newIntTypeName: #ulong code: 19 signed: false.
			SLONG := self newIntTypeName: #slong code: 20 signed: true.	
*/
		
	switch(typeCode){
		case 1:
			address = &ffi_type_void;
			break;
		case 2:
			address = &ffi_type_float;
			break;
		case 3:
			address = &ffi_type_double;
			break;

		case 4:
			address = &ffi_type_uint8;
			break;
		case 5:
			address = &ffi_type_uint16;
			break;
		case 6:
			address = &ffi_type_uint32;
			break;
		case 7:
			address = &ffi_type_uint64;
			break;

		case 8:
			address = &ffi_type_sint8;
			break;
		case 9:
			address = &ffi_type_sint16;
			break;
		case 10:
			address = &ffi_type_sint32;
			break;
		case 11:
			address = &ffi_type_sint64;
			break;

		case 12:
			address = &ffi_type_pointer;
			break;

		case 13:
			address = &ffi_type_uchar;
			break;
		case 14:
			address = &ffi_type_schar;
			break;
		case 15:
			address = &ffi_type_ushort;
			break;
		case 16:
			address = &ffi_type_sshort;
			break;
		case 17:
			address = &ffi_type_uint;
			break;
		case 18:
			address = &ffi_type_sint;
			break;
		case 19:
			address = &ffi_type_ulong;
			break;
		case 20:
			address = &ffi_type_slong;
			break;

		default:
			interpreterProxy->primitiveFailFor(1);
	}
	
	setHandler(aOop, address);
}

void* doAsyncCall(AsyncCallParameters* asyncCallParameters){

	ffi_call(asyncCallParameters->cif, asyncCallParameters->anExternalFunction, asyncCallParameters->returnHolderAddress, asyncCallParameters->parametersAddress);
	interpreterProxy->signalSemaphoreWithIndex(asyncCallParameters->semaphoreIndex);
	free(asyncCallParameters);
	return NULL;
}

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

void callbackFrontend(ffi_cif *cif, void *ret, void* args[], void* ptr){
	CallbackInvocation inv;
	CallbackData* data = ptr;

	inv.callback = data;
	inv.arguments = args;
	inv.returnHolder = ret;
	inv.semaphore = semaphore_create(0);

	addPendingCallback(&inv);
	
    semaphore_wait(inv.semaphore);	
	semaphore_release(inv.semaphore);
}


void* defineCallbackWithParamsCountReturnType(CallbackData** callbackData, ffi_type** parameters, sqInt count, ffi_type* returnType){
	CallbackData* data;
	int returnCode;
	
	data = malloc(sizeof(CallbackData));
	*callbackData = data; 
	
	data->parameterTypes = parameters;
	
	/* Allocate closure and bound_puts */
	data->closure = ffi_closure_alloc(sizeof(ffi_closure), &(data->functionAddress));
	
	if(data->closure == NULL){
		interpreterProxy->primitiveFailFor(1);
		free(data);
		free(parameters);
		*callbackData = NULL;
		return NULL;
	}
	
	if((returnCode = ffi_prep_cif(&data->cif, FFI_DEFAULT_ABI, count, returnType, parameters)) != FFI_OK){
		interpreterProxy->primitiveFailFor(1);
		ffi_closure_free(data->closure);
		free(data);
		free(parameters);
		*callbackData = NULL;
		return NULL;	
	}
		
	if((returnCode = ffi_prep_closure_loc(data->closure, &data->cif, callbackFrontend, data, data->functionAddress)) != FFI_OK){
		interpreterProxy->primitiveFailFor(1);
		ffi_closure_free(data->closure);
		free(data);
		free(parameters);
		*callbackData = NULL;
		return NULL;	
	}
	
	return data->functionAddress;
}

void callbackReturn(CallbackInvocation* invocation){
	semaphore_signal(invocation->semaphore);
}


void releaseCallback(CallbackData* data){
	ffi_closure_free(data->closure);
	free(data->parameterTypes);	
	free(data);	
}
