ffi-call
reentringCallback: aFFICallback base: anInteger 
	^ self ffiCall: #(int reentringCallback(FFICallback aFFICallback, int anInteger))