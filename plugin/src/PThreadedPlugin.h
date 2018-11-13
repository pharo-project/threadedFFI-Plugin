
#ifndef __PTREADEDPLUGIN__

#define __PTREADEDPLUGIN__

#define true 1
#define false 0
#define null 0


#include <stdio.h>
#include <ffi.h>
#include <pthread.h>
#include <errno.h>
#include <stdlib.h>
#include <strings.h>

#include "config.h"
#include "sqVirtualMachine.h"

#include "semaphoreWrapper.h"

#include "macros.h"

#ifndef FFI_OK
#define FFI_OK 0
#endif

typedef enum {
  CALLOUT,
  CALLBACK_RETURN
} WorkerTaskType;

typedef struct {
  WorkerTaskType type;
	void* anExternalFunction;
	ffi_cif* cif; 
	void* parametersAddress; 
	void* returnHolderAddress; 
	int semaphoreIndex;	
} WorkerTask;

typedef struct {
	ffi_closure* closure;
	ffi_cif cif;
	void* functionAddress;
	ffi_type** parameterTypes;
} CallbackData;

typedef struct {
	CallbackData* callback;
	void* returnHolder;
	void** arguments;
} CallbackInvocation;

#define MAX_PENDING_CALLBACKS 100

int getTypeByteSize(void* aType);

void fillBasicType(sqInt aOop);

void* doAsyncCall(WorkerTask* asyncCallParameters);

void performCallCifWithIntoUsing(void* anExternalFunction, void* aCif, void* parametersAddress, void* returnHolderAddress, int semaphoreIndex);
void performSyncCallCifWithInto(void* anExternalFunction, void* aCif, void* parametersAddress, void* returnHolderAddress);

void* defineFunctionWithAnd(ffi_type* parameters[], sqInt count, void* returnType);

void initCallbackQueue(int semaphoreIndex);
CallbackInvocation* getNextCallback();
void addPendingCallback(CallbackInvocation* aCallback);

void* defineCallbackWithParamsCountReturnType(CallbackData** callbackData, ffi_type** parameters, sqInt count, ffi_type* returnType);

void callbackReturn(CallbackInvocation* handler);

void releaseCallback(CallbackData* callbackData);

// Callout worker functions (calloutWorker.c)

sqInt initializeWorkerThread();
WorkerTask* take_queue();
void put_queue(WorkerTask* calloutParameters);
void* worker(void*);

// Util functions (utils.c)

void* getHandler(sqInt anExternalObject);
void setHandler(sqInt anExternalObject, void* value);
void* readAddress(sqInt anExternalAddress);
void writeAddress(sqInt anExternalAddress, void* value);

void* getAddressFromExternalAddressOrByteArray(sqInt anExternalAddressOrByteArray);

// Accessing the VM Functions

extern struct VirtualMachine* interpreterProxy;

#endif
