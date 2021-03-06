
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

#include "pharovm/config.h"
#include "pharovm/sqVirtualMachine.h"

#include "callbacks.h"
#include "platformSemaphore.h"
#include "macros.h"
#include "utils.h"

#ifndef FFI_OK
#define FFI_OK 0
#endif

// Accessing the VM Functions
extern struct VirtualMachine* interpreterProxy;

#endif
