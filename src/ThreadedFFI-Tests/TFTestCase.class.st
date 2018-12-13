Class {
	#name : #TFTestCase,
	#superclass : #TestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #accessing }
TFTestCase >> libraryPath [

	Smalltalk os isUnix ifTrue: [ ^ 'testLibrary.so' ].
	Smalltalk os isMacOS ifTrue: [ ^ 'testLibrary.dylib' ].
	Smalltalk os isWindows ifTrue: [ ^ 'testLibrary.dll' ].

	self error: 'Unsupported Platform'
]

{ #category : #tests }
TFTestCase >> shortCallout [
	| fun |

	fun := TFExternalFunction
		name: 'shortCallout'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition 
			parameterTypes: {} 
			returnType: TFBasicType sint32)
		worker: self worker.

	^ fun invoke
]

{ #category : #accessing }
TFTestCase >> worker [

	^ TFWorkerManager uniqueInstance defaultWorker
]
