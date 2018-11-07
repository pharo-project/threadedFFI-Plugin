Class {
	#name : #TFTestCase,
	#superclass : #TestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #accessing }
TFTestCase >> libraryPath [

	^ Smalltalk os isUnix ifTrue: [ 'testLibrary.so' ] ifFalse: [ 'testLibrary.dylib' ] 
]

{ #category : #tests }
TFTestCase >> shortCallout [
	| fun |
	fun := TFExternalFunction
		name: 'shortCallout'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition parameterTypes: {} returnType: TFBasicType sint32).

	^ fun invoke
]
