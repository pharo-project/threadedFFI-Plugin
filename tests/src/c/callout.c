#include "testLibrary.h"
#include <unistd.h>

int returnAnswer(){
	return 42;
}

int sumTwoNumbers(int a, int b){
  return a+b; 
}


float sumAFloatAndADouble(float a, double b){
  return a+b; 
}


int withDelay(int seconds){
	usleep(seconds * 1000000); // will sleep for number of seconds
  return 1;
}