Class {
	#name : #TFFunctionCallTest,
	#superclass : #TestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #'as yet unclassified' }
TFFunctionCallTest >> libraryPath [

	^ '/Users/admin/dev/Pharo/git-repos/pharo-callback-test/library/build/testLibrary.dylib'
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
