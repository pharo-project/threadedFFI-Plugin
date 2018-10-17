Class {
	#name : #TFFunctionCallTest,
	#superclass : #TestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #'as yet unclassified' }
TFFunctionCallTest >> libraryPath [

	^ 'testLibrary.dylib'
]

{ #category : #'as yet unclassified' }
TFFunctionCallTest >> testCallbackAsFunction [

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

{ #category : #'as yet unclassified' }
TFFunctionCallTest >> testCallbackInLoop [

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

{ #category : #'as yet unclassified' }
TFFunctionCallTest >> testCallbackInSingleFunction [

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

{ #category : #'as yet unclassified' }
TFFunctionCallTest >> testWithFloatAndDouble [
	| fun return |

	fun := TFExternalFunction
		name: 'sumAFloatAndADouble'
		moduleName: self libraryPath
		definition:
			(TFFunctionDefinition
				parameterTypes:
					{TFBasicType float.
					TFBasicType double}
				returnType: TFBasicType float).

	return := fun newAsyncCall
		parameters: #(1.0 2.5);
		execute.
		
	self assert: return equals: 3.5
]

{ #category : #'as yet unclassified' }
TFFunctionCallTest >> testWithTwoInts [

	| fun return |

	fun := TFExternalFunction
		name: 'sumTwoNumbers'
		moduleName: self libraryPath
		definition:
			(TFFunctionDefinition
				parameterTypes:
					{TFBasicType sint.
					TFBasicType sint}
				returnType: TFBasicType sint).
				
	return := fun newAsyncCall
					parameters:{3. 	2};
					execute.
	
	self assert: return equals: 5
]

{ #category : #'as yet unclassified' }
TFFunctionCallTest >> testWithoutArguments [
	| fun return |
	fun := TFExternalFunction
		name: 'returnAnswer'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition parameterTypes: {} returnType: TFBasicType sint32).

	return := fun newAsyncCall
		parameters: #();
		execute.

	self assert: return equals: 42.
]
