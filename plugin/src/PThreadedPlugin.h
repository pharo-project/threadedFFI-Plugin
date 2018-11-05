
#ifndef __PTREADEDPLUGIN__

#define __PTREADEDPLUGIN__

#include <stdio.h>
#include <ffi.h>
#include <pthread.h>
#include <dispatch/dispatch.h>
#include <errno.h>
#include <stdlib.h>

#include "sqVirtualMachine.h"	

typedef struct {
	void* anExternalFunction; 
	ffi_cif* cif; 
	void* parametersAddress; 
	void* returnHolderAddress; 
	int semaphoreIndex;	
} AsyncCallParameters;

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
	dispatch_semaphore_t semaphore;
} CallbackInvocation;

#define MAX_PENDING_CALLBACKS 100

sqInt initializeWorkerThread();
void* readAddress(sqInt anExternalAddress);
void writeAddress(sqInt anExternalAddress, void* value);

int getTypeByteSize(void* aType);

void* getHandler(sqInt anExternalObject);

void setHandler(sqInt anExternalObject, void* value);

void fillBasicType(sqInt aOop);

void* doAsyncCall(AsyncCallParameters* asyncCallParameters);

void performCallCifWithIntoUsing(void* anExternalFunction, void* aCif, void* parametersAddress, void* returnHolderAddress, int semaphoreIndex);
void performSyncCallCifWithInto(void* anExternalFunction, void* aCif, void* parametersAddress, void* returnHolderAddress);

void* defineFunctionWithAnd(ffi_type* parameters[], sqInt count, void* returnType);

void initCallbackQueue(int semaphoreIndex);
CallbackInvocation* getNextCallback();
void addPendingCallback(CallbackInvocation* aCallback);

void* defineCallbackWithParamsCountReturnType(CallbackData** callbackData, ffi_type** parameters, sqInt count, ffi_type* returnType);

void callbackReturn(CallbackInvocation* handler);

void releaseCallback(CallbackData* callbackData);

AsyncCallParameters* take_queue();
void put_queue(AsyncCallParameters* calloutParameters);
void* worker(void*);

#endif