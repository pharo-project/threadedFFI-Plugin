#include "PThreadedPlugin.h"

void* readAddress(sqInt anExternalAddress){
	return (*(void**)interpreterProxy->firstIndexableField(anExternalAddress));	
}

void writeAddress(sqInt anExternalAddress, void* value){
	*((void**)interpreterProxy->firstIndexableField(anExternalAddress)) = value;
}

void* getHandler(sqInt anExternalObject){	
	return readAddress(interpreterProxy->fetchPointerofObject(0, anExternalObject));
}

void setHandler(sqInt anExternalObject, void* value){
	writeAddress(interpreterProxy->fetchPointerofObject(0, anExternalObject), value);
}
