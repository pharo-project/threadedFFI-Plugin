#ifndef __PHARO_SEMAPHORE
#define __PHARO_SEMAPHORE

#include "semaphore.h"
#include "sqMemoryAccess.h"

Semaphore *pharo_semaphore_new(sqInt semaphore_index);

#endif // ifndef __PHARO_SEMAPHORE
