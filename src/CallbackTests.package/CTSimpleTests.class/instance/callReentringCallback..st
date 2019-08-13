tests
callReentringCallback: base
	| callback |
	callback := FFICallback
		signature: #(int #(int arg1))
		block: [ :arg1 | 
			self inform: arg1 asString.
			self callReentringCallback: arg1 - 1  ].
	
	^ CallbackTestsLib uniqueInstance reentringCallback: callback base: base.