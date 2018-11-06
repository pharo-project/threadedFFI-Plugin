testing
registeredCallbackReentring:base
	^ self ffiCall: #(int reentringRegisteredCallback(int base))