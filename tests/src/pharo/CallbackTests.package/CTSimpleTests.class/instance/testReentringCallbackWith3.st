tests
testReentringCallbackWith3 
	self assert: (self callReentringCallback: 2) equals: 1.
