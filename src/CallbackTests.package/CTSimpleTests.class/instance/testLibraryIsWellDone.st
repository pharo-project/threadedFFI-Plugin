tests
testLibraryIsWellDone
	self assert: (CallbackTestsLib uniqueInstance sum: 1 and: 2) equals: 3.