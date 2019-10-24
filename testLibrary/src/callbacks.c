#include "callbacks.h"

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

int doubleCallToCallbacks(SIMPLE_CALLBACK fun1, SIMPLE_CALLBACK fun2, int base) {
	int result;

	printf("Entered doubleCalltoCallbacks\n");
	fflush(stdout);

	result = fun1(base);
	result = fun2(result);
	return result;
}


