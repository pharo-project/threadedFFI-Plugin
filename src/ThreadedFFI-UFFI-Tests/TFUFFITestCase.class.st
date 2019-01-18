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
TFUFFITestCase class >> resources [ 

	^ super resources copyWith: TFTestResource
]

{ #category : #accessing }
TFUFFITestCase >> calloutAPIClass [

	^ TFCalloutAPI
]

{ #category : #accessing }
TFUFFITestCase >> ffiLibraryName [

	^ TFTestLibrary
]

{ #category : #running }
TFUFFITestCase >> runCaseManaged [

	super runCase
]

{ #category : #running }
TFUFFITestCase >> tearDown [

	"I have to reset the FFI callout methods to be recompiled using the test runner"
	self class withAllSuperclassesDo: [:each | FFIMethodRegistry uniqueInstance resetSingleClass: each].

	^ super tearDown
]

{ #category : #accessing }
TFUFFITestCase >> worker [ 
	
	^ TFTestResource current worker
]
