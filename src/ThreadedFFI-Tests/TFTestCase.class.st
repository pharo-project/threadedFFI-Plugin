Class {
	#name : #TFTestCase,
	#superclass : #TestCase,
	#instVars : [
		'runner'
	],
	#category : #'ThreadedFFI-Tests'
}

{ #category : #accessing }
TFTestCase >> libraryPath [

	Smalltalk os isUnix ifTrue: [ ^ 'testLibrary.so' ].
	Smalltalk os isMacOS ifTrue: [ ^ 'testLibrary.dylib' ].
	Smalltalk os isWindows ifTrue: [ ^ 'testLibrary.dll' ].

	self error: 'Unsupported Platform'
]

{ #category : #running }
TFTestCase >> runCaseManaged [

	super runCase
]

{ #category : #accessing }
TFTestCase >> setUp [ 

	super setUp.
	
	runner := TFWorker named: 'testRunner'.
]

{ #category : #tests }
TFTestCase >> shortCallout [
	| fun |
	fun := TFExternalFunction
		name: 'shortCallout'
		moduleName: self libraryPath
		definition:
			(TFFunctionDefinition
				parameterTypes: {}
				returnType: TFBasicType sint32).

	^ runner invokeFunction: fun 
]
