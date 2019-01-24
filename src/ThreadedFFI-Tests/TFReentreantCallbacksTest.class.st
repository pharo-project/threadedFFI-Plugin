Class {
	#name : #TFReentreantCallbacksTest,
	#superclass : #TFTestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #tests }
TFReentreantCallbacksTest >> testReentrantCalloutsDuringCallback [

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
TFReentreantCallbacksTest >> testSingleCalloutDuringCallback [

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
