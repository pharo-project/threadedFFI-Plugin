testing
registerCallback: aFFICallback
	self ffiCall: #(void registerCallback(FFICallback aFFICallback))