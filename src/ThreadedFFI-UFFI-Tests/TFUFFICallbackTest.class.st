Class {
	#name : #TFUFFICallbackTest,
	#superclass : #TFUFFITestCase,
	#category : #'ThreadedFFI-UFFI-Tests'
}

{ #category : #tests }
TFUFFICallbackTest >> callbackInALoop: callback [

	^ self ffiCall: #(int callbackInALoop(void* callback))
]

{ #category : #accessing }
TFUFFICallbackTest >> ffiLibraryName [

	^ Smalltalk os isUnix ifTrue: [ 'testLibrary.so' ] ifFalse: [ 'testLibrary.dylib' ] 
]

{ #category : #tests }
TFUFFICallbackTest >> returnAnswer [

	^ self ffiCall: #(int32 returnAnswer())
]

{ #category : #tests }
TFUFFICallbackTest >> shortCallout [
	
	^ self ffiCall: #(int shortCallout())
]

{ #category : #tests }
TFUFFICallbackTest >> singleCallToCallback: callback value: value [

	^ self ffiCall: #(int singleCallToCallback(void* callback, int value))
]

{ #category : #tests }
TFUFFICallbackTest >> sumFloat: a andDouble: b [

	^ self ffiCall: #(float sumAFloatAndADouble(float a, double b))
]

{ #category : #tests }
TFUFFICallbackTest >> sumInt:a andInt: b [

	^ self ffiCall: #(int sumTwoNumbers(int a, int b))
]

{ #category : #tests }
TFUFFICallbackTest >> testCallbackAsFunction [

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
TFUFFICallbackTest >> testCallbackInLoop [

	| callback |

	callback := self
		newCallbackWithSignature: #(int (int a))
		block: [ :a | a + 1 ].

	self assert: (self callbackInALoop: callback) equals: 42

]

{ #category : #tests }
TFUFFICallbackTest >> testCallbackInSingleFunction [

	| callback |

	callback := self newCallbackWithSignature: #(int (int a)) block: [ :a | a + 1 ].
	self assert: (self singleCallToCallback: callback value: 3) equals: 5

]
