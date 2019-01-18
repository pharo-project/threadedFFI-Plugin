#include "PThreadedPlugin.h"

/*** Variables ***/

struct VirtualMachine* interpreterProxy;
static const char *moduleName = "PThreadedPlugin * ThreadedFFI-Plugin-PGE.1 (:P)";

const char * getModuleName(void){
	return moduleName;
}

sqInt initialiseModule(void){
    return 1;
}

sqInt setInterpreter(struct VirtualMachine* anInterpreter)
{
    sqInt ok;

	interpreterProxy = anInterpreter;
	ok = ((interpreterProxy->majorVersion()) == (VM_PROXY_MAJOR))
	 && ((interpreterProxy->minorVersion()) >= (VM_PROXY_MINOR));

	if(!ok){
		printf("Incompatible Plugin version:\n");
	    printf("Major: VM:%d Plugin:%d \n", (int)interpreterProxy->majorVersion(), (int)VM_PROXY_MAJOR );
	    printf("Minor: VM:%d Plugin:%d \n", (int)interpreterProxy->minorVersion(), (int)VM_PROXY_MINOR );
	}

	return ok;
}
