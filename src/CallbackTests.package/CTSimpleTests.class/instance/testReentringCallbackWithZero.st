tests
testReentringCallbackWithZero	
	self assert: (self callReentringCallback: 0) equals: 1.
