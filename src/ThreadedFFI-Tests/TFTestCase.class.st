Class {
	#name : #TFTestCase,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'runner'
	],
	#category : #'ThreadedFFI-Tests'
}

{ #category : #'building suites' }
TFTestCase class >> testParameters [ 

	^ ParametrizedTestMatrix new
		forSelector: #runner addOptions: { "[TFWorker default]. "[ TFSameThreadRunner new ] }
]

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
TFTestCase >> runner [
	^ runner
]

{ #category : #accessing }
TFTestCase >> runner: anObject [
	runner := anObject
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
