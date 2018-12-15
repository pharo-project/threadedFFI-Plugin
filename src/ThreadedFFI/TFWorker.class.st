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

{ #category : #'instance creation' }
TFWorker class >> new [

	self error: 'Workers are created by the worker manager'
]

{ #category : #private }
TFWorker class >> newHandle: aHandle name: aName [ 

	^ self basicNew 
		initializeHandle: aHandle name: aName;
		yourself
]

{ #category : #accessing }
TFWorker >> handle [

	^ handle
]

{ #category : #initialization }
TFWorker >> initialize [
	
	super initialize.
	callbackQueue := TFWorkerCallbackQueue on: self
]

{ #category : #initialization }
TFWorker >> initializeHandle: aHandle name: aString. [

	handle := aHandle.
	name := aString.
	self initialize.

]

{ #category : #'accessing callbacks' }
TFWorker >> lookupCallback: aCallback [
	
	^ callbackQueue lookupCallback: aCallback
]

{ #category : #accessing }
TFWorker >> name [

	^ name
]

{ #category : #'accessing callbacks' }
TFWorker >> registerCallback: aCallback [
 
	callbackQueue registerCallback: aCallback
]

{ #category : #'system startup' }
TFWorker >> shutDown [ 

	callbackQueue shutDown
]
