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
TFUFFITestCase >> newExecutionEnvironment [
	
	^ TFExecutionEnvironment new
]

{ #category : #running }
TFUFFITestCase >> runCase [

	CurrentExecutionEnvironment value: self newExecutionEnvironment. 
	super runCase
]

{ #category : #running }
TFUFFITestCase >> runCaseManaged [

	super runCase
]

{ #category : #running }
TFUFFITestCase >> tearDown [

	"I have to reset the FFI callout methods to be recompiled using the test runner"
	FFIMethodRegistry uniqueInstance resetSingleClass: self class.

	^ super tearDown
]

{ #category : #accessing }
TFUFFITestCase >> worker [ 
	
	^ TFTestResource current worker
]
