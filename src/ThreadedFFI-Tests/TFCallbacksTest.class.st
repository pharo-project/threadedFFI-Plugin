Class {
	#name : #TFCallbacksTest,
	#superclass : #TFTestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #'as yet unclassified' }
TFCallbacksTest >> callCallback: aCallback [
	
	| functionDefinition function |
	functionDefinition := TFFunctionDefinition
		parameterTypes: {}
		returnType: TFBasicType void.
	function := TFExternalFunction fromAddress: aCallback getHandle 
		definition: functionDefinition.

	runner invokeFunction: function withArguments: {}
]

{ #category : #'instance creation' }
TFCallbacksTest >> newTestCallbackDoing: aBlock [
	
	^ TFCallback 
		forCallback: aBlock 
		parameters: {} 
		returnType: TFBasicType void
		runner: runner.
]

{ #category : #tests }
TFCallbacksTest >> setUp [

	super setUp.
	runner exceptionHandler: TFTestCallbackExceptionHandler new
]

{ #category : #tests }
TFCallbacksTest >> tearDown [

	runner release.
	super tearDown
]

{ #category : #tests }
TFCallbacksTest >> testCallbackNotRespectingLIFOOrderFailsReturn [

	| smain s1 c1 s2 c2 |
	smain := Semaphore new.

	s1 := Semaphore new.
	c1 := self newTestCallbackDoing: [ smain signal. s1 wait ].

	s2 := Semaphore new.
	c2 := self newTestCallbackDoing: [ smain signal. s2 wait ].
	
	[ self callCallback: c1 ] fork.
	[ self callCallback: c2 ] fork.

	"wait until both callbacks arrive"
	smain wait; wait.
	
	"make callback 1 to finish while callback 2 is suspended"
	s1 signal.

	runner exceptionHandler wait.

	self assert: runner exceptionHandler lastException class equals: TFIncorrectOrderCallbackReturn.
	self assert: runner exceptionHandler lastException callback equals: c1.
	self
		assert: (runner exceptionHandler lastException previousCallbacks collect: #callback as: Array)
		equals: { c2 }.
]

{ #category : #tests }
TFCallbacksTest >> testReentrantCalloutsDuringCallback [

	| callback fun returnValue |
	"Avoid running this test before the image side support handles this case.
	Otherwise both the UI thread and the callback management thread will get blocked in a deadlock."
	"true ifTrue: [ ^ self skip ]."
	
	fun := TFExternalFunction
		name: 'singleCallToCallback'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition
			parameterTypes: {TFBasicType pointer. TFBasicType sint}
			returnType: TFBasicType sint).

	callback := TFCallback 
		forCallback: [ :times | 
			times = 7
				ifTrue: [ times ]
				ifFalse: [ runner invokeFunction: fun withArguments: {callback getHandle. times + 1} ] ] 
		parameters: { TFBasicType sint. } 
		returnType: TFBasicType sint
		runner: runner.

	returnValue := runner invokeFunction: fun withArguments: {callback getHandle. 0}.
	self assert: returnValue equals: 7
]

{ #category : #tests }
TFCallbacksTest >> testSingleCalloutDuringCallback [

	| callback fun returnValue |

	callback := TFCallback 
		forCallback: [ :a | self shortCallout ] 
		parameters: { TFBasicType sint. } 
		returnType: TFBasicType sint
		runner: runner.

	fun := TFExternalFunction
		name: 'singleCallToCallback'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition
			parameterTypes: {TFBasicType pointer. TFBasicType sint}
			returnType: TFBasicType sint).

	returnValue := runner invokeFunction: fun withArguments: {callback getHandle. 3}.
	self assert: returnValue equals: 42
]
