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
