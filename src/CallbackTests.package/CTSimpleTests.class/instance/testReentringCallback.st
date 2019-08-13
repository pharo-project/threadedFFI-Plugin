tests
testReentringCallback	
	self assert: (self callReentringCallback: 1) equals: 1.
