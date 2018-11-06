Class {
	#name : #TUFFIFunctionCallTest,
	#superclass : #TFUFFITestCase,
	#category : #'ThreadedFFI-UFFI-Tests'
}

{ #category : #tests }
TUFFIFunctionCallTest >> callbackInALoop: callback [

	^ self ffiCall: #(int callbackInALoop(void* callback))
]

{ #category : #accessing }
TUFFIFunctionCallTest >> ffiLibraryName [

	^ Smalltalk os isUnix ifTrue: [ 'testLibrary.so' ] ifFalse: [ 'testLibrary.dylib' ] 
]

{ #category : #tests }
TUFFIFunctionCallTest >> returnAnswer [

	^ self ffiCall: #(int32 returnAnswer())
]

{ #category : #tests }
TUFFIFunctionCallTest >> singleCallToCallback: callback value: value [

	^ self ffiCall: #(int singleCallToCallback(void* callback, int value))
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

	| callback fun definition |
	callback := self
		newCallbackWithSignature: #(float (int a, float b))
		block: [ :a :b | a + b ].
	callback parameterTypes at: 1 put: TFBasicType sint.
	definition := TFFunctionDefinition
		parameterTypes: {TFBasicType sint. TFBasicType float.}
		returnType: TFBasicType float.

	fun := TFExternalFunction 
		fromAddress: callback getHandle 
		definition: definition.

	self assert: (fun invokeWithArguments: {1. 2.0}) equals: 3.0
]

{ #category : #tests }
TUFFIFunctionCallTest >> testCallbackInLoop [

	| callback |

	callback := self
		newCallbackWithSignature: #(int (int a))
		block: [ :a | a + 1 ].

	self assert: (self callbackInALoop: callback) equals: 42

]

{ #category : #tests }
TUFFIFunctionCallTest >> testCallbackInSingleFunction [

	| callback |

	callback := self newCallbackWithSignature: #(int (int a)) block: [ :a | a + 1 ].
	self assert: (self singleCallToCallback: callback value: 3) equals: 5

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
