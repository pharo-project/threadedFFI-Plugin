"
I'm a threaded ffi worker. 
A worker handles callouts/callbacks in a real thread of the system.

Creating a worker has several consquences both in image and in VM: 

Image side, it creates a process responsible to handle all callback requests from vm.
VM side, it creates a thread and installs a worker there, responsible to collect callouts and callbacks.


"
Class {
	#name : #TFWorker,
	#superclass : #Object,
	#instVars : [
		'handle',
		'name',
		'callbackQueue'
	],
	#category : #'ThreadedFFI-Worker'
}

{ #category : #private }
TFWorker class >> named: aName [

	^ self basicNew 
		name: aName;
		initialize;
		yourself
]

{ #category : #'instance creation' }
TFWorker class >> new [

	self error: 'Workers are created by the worker manager'
]

{ #category : #accessing }
TFWorker >> handle [

	^ handle
]

{ #category : #initialization }
TFWorker >> initialize [
	
	super initialize.
	callbackQueue := TFWorkerCallbackQueue on: self.
]

{ #category : #'accessing callbacks' }
TFWorker >> lookupCallback: aCallback [
	
	^ callbackQueue lookupCallback: aCallback
]

{ #category : #accessing }
TFWorker >> name [

	^ name
]

{ #category : #accessing }
TFWorker >> name: aName [

	name := aName
]

{ #category : #initialization }
TFWorker >> register [

	handle := self registerWorker: name asString queueIndex: callbackQueue semaphoreIndex.
]

{ #category : #'accessing callbacks' }
TFWorker >> registerCallback: aCallback [
 
	callbackQueue registerCallback: aCallback
]

{ #category : #initialization }
TFWorker >> registerWorker: aName queueIndex: index [
	<primitive: #primitiveRegisterWorker module: #PThreadedPlugin>
	
	^ self primitiveFailed
]

{ #category : #'system startup' }
TFWorker >> shutDown [ 

	callbackQueue shutDown
]
