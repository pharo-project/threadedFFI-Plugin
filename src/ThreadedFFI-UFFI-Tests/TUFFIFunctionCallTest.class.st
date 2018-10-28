Class {
	#name : #TUFFIFunctionCallTest,
	#superclass : #TestCase,
	#category : #'ThreadedFFI-UFFI-Tests'
}

{ #category : #accessing }
TUFFIFunctionCallTest >> calloutAPIClass [

	^ TFCalloutAPI
]

{ #category : #accessing }
TUFFIFunctionCallTest >> ffiLibraryName [

	^ 'testLibrary.dylib'
]

{ #category : #tests }
TUFFIFunctionCallTest >> returnAnswer [

1halt.
	^ self ffiCall: #(int32 returnAnswer())
]

{ #category : #tests }
TUFFIFunctionCallTest >> sumFloat: a andDouble: b [

	^ self ffiCall: #(float sumAFloatAndADouble(float a, double b))
]

{ #category : #tests }
TUFFIFunctionCallTest >> sumInt:a andInt: b [

	^ self ffiCall: #(int sumTwoNumbers(int a, int b))
]

{ #category : #tests }
TUFFIFunctionCallTest >> testCallbackAsFunction [

	| callback fun definition returnValue |

	callback := TFCallback 
		forBlock: [ :a :b | a + b ] 
		parameters: { TFBasicType sint. TFBasicType float } 
		returnType: TFBasicType float.

	definition := TFFunctionDefinition
				parameterTypes: {TFBasicType sint. TFBasicType float.}
				returnType: TFBasicType float.

	fun := TFExternalFunction 
		fromAddress: callback getHandle 
		definition: definition.
	
	returnValue := fun newAsyncCall 
		parameters: {1. 2.0};
		execute.
		
	self assert: returnValue equals: 3.0
]

{ #category : #tests }
TUFFIFunctionCallTest >> testCallbackInLoop [

	| callback fun returnValue |

	callback := TFCallback 
		forBlock: [ :a | a + 1 ] 
		parameters: { TFBasicType sint. } 
		returnType: TFBasicType sint.

	fun := TFExternalFunction
		name: 'callbackInALoop'
		moduleName: self libraryPath
		definition:
			(TFFunctionDefinition
				parameterTypes:
					{TFBasicType pointer}
				returnType: TFBasicType sint).

	returnValue := fun newAsyncCall 
		parameters: {callback getHandle};
		execute.

	self assert: returnValue equals: 42

]

{ #category : #tests }
TUFFIFunctionCallTest >> testCallbackInSingleFunction [

	| callback fun returnValue |

	callback := TFCallback 
		forBlock: [ :a | a + 1 ] 
		parameters: { TFBasicType sint. } 
		returnType: TFBasicType sint.

	fun := TFExternalFunction
		name: 'singleCallToCallback'
		moduleName: self libraryPath
		definition:
			(TFFunctionDefinition
				parameterTypes: {TFBasicType pointer. TFBasicType sint}
				returnType: TFBasicType sint).

	returnValue := fun newAsyncCall 
		parameters: {callback getHandle. 3};
		execute.

	self assert: returnValue equals: 5

]

{ #category : #tests }
TUFFIFunctionCallTest >> testWithFloatAndDouble [
	
	self assert: (self sumFloat: 1.0 andDouble: 2.5) equals: 3.5
]

{ #category : #tests }
TUFFIFunctionCallTest >> testWithTwoInts [

	self assert: (self sumInt: 2 andInt: 3) equals: 5
]

{ #category : #tests }
TUFFIFunctionCallTest >> testWithoutArguments [

	self assert: self returnAnswer equals: 42.
]
