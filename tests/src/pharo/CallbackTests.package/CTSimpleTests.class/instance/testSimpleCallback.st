tests
testSimpleCallback
	| callback callbackValue |
	callback := FFICallback
		signature: #(int #(int arg1))
		block: [ :arg1 | (callbackValue := arg1) + 1 ].
		
	self assert: (CallbackTestsLib uniqueInstance singleCallToCallback: callback base: 42) equals: 44.
	self assert: callbackValue equals: 43.