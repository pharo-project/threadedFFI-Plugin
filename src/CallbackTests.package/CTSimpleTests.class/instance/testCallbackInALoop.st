tests
testCallbackInALoop
	| callback callbackValue |
	callback := FFICallback
		signature: #(int #(int arg1))
		block: [ :arg1 | (callbackValue := arg1) + 1 ].
		
	self assert: (CallbackTestsLib uniqueInstance callbackInALoop: callback ) equals: 42.
	self assert: callbackValue equals: 41.