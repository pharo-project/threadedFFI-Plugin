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
	true ifTrue: [ ^ self skip ].
	
	fun := TFExternalFunction
		name: 'singleCallToCallback'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition
			parameterTypes: {TFBasicType pointer. TFBasicType sint}
			returnType: TFBasicType sint)
		worker: self worker.

	callback := TFCallback 
		forCallback: [ :times | 
			times = 42
				ifTrue: [ times ]
				ifFalse: [ fun invokeWithArguments: {callback getHandle. times + 1} ] ] 
		parameters: { TFBasicType sint. } 
		returnType: TFBasicType sint
		worker: self worker.

	returnValue := fun invokeWithArguments: {callback getHandle. 0}.
	self assert: returnValue equals: 42
]

{ #category : #tests }
TFReentreantCallbacksTest >> testSingleCalloutDuringCallback [

	| callback fun returnValue |

	callback := TFCallback 
		forCallback: [ :a | self shortCallout ] 
		parameters: { TFBasicType sint. } 
		returnType: TFBasicType sint
		worker: runner.

	fun := TFExternalFunction
		name: 'singleCallToCallback'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition
			parameterTypes: {TFBasicType pointer. TFBasicType sint}
			returnType: TFBasicType sint).

	returnValue := runner invokeFunction: fun withArguments: {callback getHandle. 3}.
	self assert: returnValue equals: 42
]
