Class {
	#name : #TFTestCase,
	#superclass : #TestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #accessing }
TFTestCase >> libraryPath [

	^ Smalltalk os isUnix ifTrue: [ 'testLibrary.so' ] ifFalse: [ 'testLibrary.dylib' ] 
]
