Class {
	#name : #TFUFFITestCase,
	#superclass : #TestCase,
	#category : #'ThreadedFFI-UFFI-Tests'
}

{ #category : #testing }
TFUFFITestCase class >> isAbstract [

	^ self == TFUFFITestCase
]

{ #category : #accessing }
TFUFFITestCase >> calloutAPIClass [

	^ TFCalloutAPI
]

{ #category : #accessing }
TFUFFITestCase >> ffiLibraryName [

	^ Smalltalk os isUnix ifTrue: [ 'testLibrary.so' ] ifFalse: [ 'testLibrary.dylib' ] 
]