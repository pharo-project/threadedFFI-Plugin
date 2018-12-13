Class {
	#name : #TFFunctionCallTest,
	#superclass : #TFTestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #tests }
TFFunctionCallTest >> testCallbackAsFunction [

	| callback fun definition returnValue |

	callback := TFCallback 
		forCallback: [ :a :b | a + b ] 
		parameters: { TFBasicType sint. TFBasicType float } 
		returnType: TFBasicType float
		worker: self worker.

	definition := TFFunctionDefinition
		parameterTypes: {TFBasicType sint. TFBasicType float.}
		returnType: TFBasicType float.

	fun := TFExternalFunction 
		fromAddress: callback getHandle 
		definition: definition
		worker: self worker.
	
	
	returnValue := fun newCall 
		parameters: {1. 2.0};
		execute.
		
	self assert: returnValue equals: 3.0
]

{ #category : #tests }
TFFunctionCallTest >> testCallbackInLoop [

	| callback fun returnValue |

	callback := TFCallback 
		forCallback: [ :a | a + 1 ] 
		parameters: { TFBasicType sint. } 
		returnType: TFBasicType sint
		worker: self worker.

	fun := TFExternalFunction
		name: 'callbackInALoop'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition
			parameterTypes: {TFBasicType pointer}
			returnType: TFBasicType sint)
		worker: self worker.

	returnValue := fun newCall 
		parameters: {callback getHandle};
		execute.

	self assert: returnValue equals: 42

]

{ #category : #tests }
TFFunctionCallTest >> testCallbackInSingleFunction [

	| callback fun returnValue |

	callback := TFCallback 
		forCallback: [ :a | a + 1 ] 
		parameters: { TFBasicType sint. } 
		returnType: TFBasicType sint
		worker: self worker.

	fun := TFExternalFunction
		name: 'singleCallToCallback'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition
			parameterTypes: {TFBasicType pointer. TFBasicType sint}
			returnType: TFBasicType sint)
		worker: self worker.

	returnValue := fun newCall
		parameters: {callback getHandle. 3};
		execute.

	self assert: returnValue equals: 5

]

{ #category : #tests }
TFFunctionCallTest >> testWithFloatAndDouble [
	| fun return |

	fun := TFExternalFunction
		name: 'sumAFloatAndADouble'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition
			parameterTypes: { TFBasicType float. TFBasicType double }
			returnType: TFBasicType float)
		worker: self worker.

	return := fun newCall
		parameters: #(1.0 2.5);
		execute.
		
	self assert: return equals: 3.5
]

{ #category : #tests }
TFFunctionCallTest >> testWithTwoInts [

	| fun return |

	fun := TFExternalFunction
		name: 'sumTwoNumbers'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition
			parameterTypes: { TFBasicType sint. TFBasicType sint }
			returnType: TFBasicType sint)
		worker: self worker.
				
	return := fun newCall
					parameters:{3. 	2};
					execute.
	
	self assert: return equals: 5
]

{ #category : #tests }
TFFunctionCallTest >> testWithoutArguments [
	
	self assert: self shortCallout equals: 42.
]
