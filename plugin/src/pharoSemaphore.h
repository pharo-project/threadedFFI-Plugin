#ifndef __PHARO_SEMAPHORE
#define __PHARO_SEMAPHORE

#include "semaphore.h"
#include "sqMemoryAccess.h"

Semaphore *make_pharo_semaphore(sqInt semaphore_index);

#endif // ifndef __PHARO_SEMAPHORE
