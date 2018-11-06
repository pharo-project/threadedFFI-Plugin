#include "testLibrary.h"

int singleCallToCallback(SIMPLE_CALLBACK fun, int base){
	return fun(base + 1);
}

int callbackInALoop(SIMPLE_CALLBACK fun){
	int i;
	int acc = 0;
	
	for(i=0;i<42;i++){
		acc = fun(acc);
	}
	
	return acc;
}

int reentringCallback(SIMPLE_CALLBACK fun, int base){
	printf("Value entered: %d\n", base);

	if(base == 0)
		return 1;

	return fun(base);
}