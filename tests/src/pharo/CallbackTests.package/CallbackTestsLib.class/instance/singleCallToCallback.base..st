testing
singleCallToCallback: aFFICallback base: anInteger 
	self ffiCall: #(int singleCallToCallback(FFICallback aFFICallback, int anInteger))