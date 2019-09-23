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
TFCallbacksTest >> testReentrantCalloutsDuringCallback [
	| callback fun returnValue |
	"Avoid running this test before the image side support handles this case.
	Otherwise both the UI thread and the callback management thread will get blocked in a deadlock."
	"true ifTrue: [ ^ self skip ]."
	fun := TFExternalFunction
		name: 'singleCallToCallback'
		moduleName: self libraryPath
		definition:
			(TFFunctionDefinition
				parameterTypes:
					{TFBasicType pointer.
					TFBasicType sint}
				returnType: TFBasicType sint).
	callback := TFCallback
		forCallback: [ :times | 
			times traceCr.
			times = 7
				ifTrue: [ times ]
				ifFalse: [ runner
						invokeFunction: fun
						withArguments:
							{callback getHandle.
							(times + 1)} ] ]
		parameters: {TFBasicType sint}
		returnType: TFBasicType sint
		runner: runner.
	returnValue := runner
		invokeFunction: fun
		withArguments:
			{callback getHandle.
			0}.
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
