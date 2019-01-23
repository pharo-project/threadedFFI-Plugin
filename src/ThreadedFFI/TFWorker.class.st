"
I'm a threaded ffi worker. 
A worker handles callouts/callbacks in a real thread of the system.

Creating a worker has several consquences both in image and in VM: 

Image side, it creates a process responsible to handle all callback requests from vm.
VM side, it creates a thread and installs a worker there, responsible to collect callouts and callbacks.


"
Class {
	#name : #TFWorker,
	#superclass : #FFIExternalObject,
	#instVars : [
		'name'
	],
	#category : #'ThreadedFFI-Worker'
}

{ #category : #private }
TFWorker class >> finalizeResourceData: handle [

	handle isNull ifTrue: [ ^ self ].
	
	(self fromHandle: handle)
		release.
		
	handle beNull.
]

{ #category : #private }
TFWorker class >> named: aName [

	^ self new 
		name: aName;
		autoRelease;
		yourself
]

{ #category : #accessing }
TFWorker >> ensureInitialized [
	
	self isNull ifTrue: [ self primitiveCreateWorker ]
]

{ #category : #executing }
TFWorker >> executeFunction: aTFExternalFunction withArguments: argumentHolder withReturnHolder: aReturnHolder usingSemaphore: anInteger [ 
	
	self ensureInitialized.
	^ self primitivePerformWorkerCall: aTFExternalFunction withArguments: argumentHolder withReturnHolder: aReturnHolder usingSemaphore: anInteger 
]

{ #category : #execution }
TFWorker >> invokeFunction: aTFExternalFunction [ 
	
	^ self invokeFunction: aTFExternalFunction withArguments: #()
]

{ #category : #executing }
TFWorker >> invokeFunction: aTFExternalFunction withArguments: aCollection [ 

	^ aTFExternalFunction newCall
		parameters: aCollection;
		executeOn: self
]

{ #category : #accessing }
TFWorker >> name [

	^ name
]

{ #category : #accessing }
TFWorker >> name: aName [

	name := aName
]

{ #category : #accessing }
TFWorker >> primitiveCreateWorker [

	<primitive: 'primitiveCreateWorker' module: 'PThreadedPlugin'>

	^ self primitiveFailed 
]

{ #category : #executing }
TFWorker >> primitivePerformWorkerCall: aTFExternalFunction withArguments: argumentHolder withReturnHolder: aReturnHolder usingSemaphore: anInteger [ 
	
	<primitive: 'primitivePerformWorkerCall' module: 'PThreadedPlugin'>

	^ self primitiveFailed 
]

{ #category : #accessing }
TFWorker >> primitiveReleaseWorker [

	<primitive: 'primitiveReleaseWorker' module: 'PThreadedPlugin'>

	^ self primitiveFailed 
]

{ #category : #accessing }
TFWorker >> release [ 
	
	self isNull ifFalse: [ self primitiveReleaseWorker ]
]
