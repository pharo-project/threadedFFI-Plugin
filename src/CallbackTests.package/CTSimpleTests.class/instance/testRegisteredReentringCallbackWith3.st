tests
testRegisteredReentringCallbackWith3 
	| callback |
	callback := FFICallback
		signature: #(int #(int arg1))
		block: [ :arg1 | CallbackTestsLib uniqueInstance registeredCallbackReentring: arg1 - 1 ].

	CallbackTestsLib uniqueInstance registerCallback: callback.
	self assert: (CallbackTestsLib uniqueInstance registeredCallbackReentring: 3) equals: 1.
