#include "PThreadedPlugin.h"

void* readAddress(sqInt anExternalAddress){
	if(!interpreterProxy->isKindOfClass(anExternalAddress, interpreterProxy->classExternalAddress())){
		interpreterProxy->primitiveFail();
		return NULL;
	}

	return (*(void**)interpreterProxy->firstIndexableField(anExternalAddress));	
}

void writeAddress(sqInt anExternalAddress, void* value){
	if(!interpreterProxy->isKindOfClass(anExternalAddress, interpreterProxy->classExternalAddress())){
		interpreterProxy->primitiveFail();
		return;
	}

	*((void**)interpreterProxy->firstIndexableField(anExternalAddress)) = value;
}

sqInt getAttributeOf(sqInt receiver, int index) {
    return interpreterProxy->fetchPointerofObject(index, receiver);
}

void *getHandlerOf(sqInt receiver, int index) {
    return readAddress(getAttributeOf(receiver, index));
}

void* getHandler(sqInt anExternalObject){	
	if(!(interpreterProxy->isPointers(anExternalObject) && interpreterProxy->slotSizeOf(anExternalObject) >= 1)) {
		interpreterProxy->primitiveFail();
		return NULL;
	}

	return readAddress(interpreterProxy->fetchPointerofObject(0, anExternalObject));
}

void setHandler(sqInt anExternalObject, void* value){
	if(!(interpreterProxy->isPointers(anExternalObject) && interpreterProxy->slotSizeOf(anExternalObject) >= 1)) {
		interpreterProxy->primitiveFail();
		return;
	}
	writeAddress(interpreterProxy->fetchPointerofObject(0, anExternalObject), value);
}

void* getAddressFromExternalAddressOrByteArray(sqInt anExternalAddressOrByteArray){
	if(interpreterProxy->isKindOfClass(anExternalAddressOrByteArray, interpreterProxy->classExternalAddress())){
		return readAddress(anExternalAddressOrByteArray);
	}

	if(interpreterProxy->isKindOfClass(anExternalAddressOrByteArray, interpreterProxy->classByteArray())){
		return interpreterProxy->firstIndexableField(anExternalAddressOrByteArray);
	}

	interpreterProxy->primitiveFail();
	return NULL;
}

char *readString(sqInt aString) {
    if(!interpreterProxy->isKindOfClass(aString, interpreterProxy->classString())){
        interpreterProxy->primitiveFail();
        return NULL;
    }
    
    return (char *)interpreterProxy->firstIndexableField(aString);
}

inline sqInt getReceiver() {
    return interpreterProxy->stackValue(interpreterProxy->methodArgumentCount());
}

inline void primitiveEnd() {
    //pop all execept receiver, which will be answered (^self)
    interpreterProxy->pop(interpreterProxy->methodArgumentCount());
}

inline void primitiveEndReturn(sqInt ret) {
    //pop all including receiver, we are answering our own result
    interpreterProxy->pop(interpreterProxy->methodArgumentCount() + 1);
    interpreterProxy->push(ret);
}

inline void primitiveEndReturnInteger(int ret) {
    interpreterProxy->pop(interpreterProxy->methodArgumentCount() + 1);
    interpreterProxy->pushInteger(ret);
}

inline sqInt newExternalAddress() {
    return interpreterProxy->instantiateClassindexableSize(interpreterProxy->classExternalAddress(), sizeof(void*));
}
