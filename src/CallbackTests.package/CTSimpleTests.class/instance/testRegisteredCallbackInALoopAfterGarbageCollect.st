tests
testRegisteredCallbackInALoopAfterGarbageCollect
	
	| callback |
	callback := FFICallback
		signature: #(int #(int arg1))
		block: [ :arg1 | arg1 + 1 ].
	
	1 to: 20 do: [:x | Smalltalk garbageCollect]. 
	
	CallbackTestsLib uniqueInstance registerCallback: callback.	
	self assert: (CallbackTestsLib uniqueInstance registeredCallbackInALoop ) equals: 42.
	