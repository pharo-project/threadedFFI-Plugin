testing
callbackInALoop: aFFICallback
	self ffiCall: #(int callbackInALoop(FFICallback aFFICallback))