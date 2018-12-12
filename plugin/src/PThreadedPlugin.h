
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
#include <string.h>

#include "config.h"
#include "sqVirtualMachine.h"

#include "workerTask.h"
#include "worker.h"
#include "callbacks.h"
#include "semaphore.h"
#include "macros.h"
#include "utils.h"

#ifndef FFI_OK
#define FFI_OK 0
#endif

int getTypeByteSize(void* aType);
void fillBasicType(sqInt aOop);

void *defineFunctionWithAnd(ffi_type* parameters[], sqInt count, void* returnType);

// Accessing the VM Functions
extern struct VirtualMachine* interpreterProxy;

#endif
