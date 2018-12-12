#ifndef __UTILS__
#define __UTILS__

#include "sqVirtualMachine.h"

void *getHandler(sqInt anExternalObject);
void setHandler(sqInt anExternalObject, void* value);
void *readAddress(sqInt anExternalAddress);
void writeAddress(sqInt anExternalAddress, void* value);
char *readString(sqInt aString);
void *getAddressFromExternalAddressOrByteArray(sqInt anExternalAddressOrByteArray);

// meta
sqInt getReceiver();
sqInt getAttributeOf(sqInt receiver, int index);
void *getHandlerOf(sqInt receiver, int index);
// clean ending for a primitive
void primitiveEnd();
void primitiveEndReturn(sqInt ret);
void primitiveEndReturnInteger(int ret);
// others
sqInt newExternalAddress();

#endif
