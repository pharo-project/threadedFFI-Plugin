tests
testRegisteredCallbackInALoop
	| callback |
	callback := FFICallback
		signature: #(int #(int arg1))
		block: [ :arg1 | arg1 + 1 ].
		
	CallbackTestsLib uniqueInstance registerCallback: callback.
	self assert: CallbackTestsLib uniqueInstance registeredCallbackInALoop equals: 42