"
I'm a callback queue associated to a worker.
I handle all callbacks defined in the context of a worker.
"
Class {
	#name : #TFCallbackQueue,
	#superclass : #Object,
	#instVars : [
		'worker',
		'semaphore',
		'semaphoreIndex',
		'callbacks',
		'pendingQueue',
		'callbackProcess'
	],
	#classVars : [
		'UniqueInstance'
	],
	#category : #'ThreadedFFI-Callbacks'
}

{ #category : #'instance creation' }
TFCallbackQueue class >> new [

	self error: 'Use #on:'
]

{ #category : #'instance creation' }
TFCallbackQueue class >> on: aWorker [
	
	^ self basicNew 
		initializeWorker: aWorker;
		yourself
]

{ #category : #operations }
TFCallbackQueue >> executeCallback: aCallback [
	
	aCallback getHandle isNull ifFalse: [ 
		[ [ aCallback execute ] 
			on: Error 
			fork: [ :e | e pass ] ] fork ]
]

{ #category : #initialization }
TFCallbackQueue >> forkCallbackProcess [
	
	callbackProcess ifNotNil: [ ^ self ].
	callbackProcess := [
		[ true ] whileTrue: [
			semaphore wait.
			self executeCallback: self nextPendingCallback ] ] 
		forkAt: Processor highIOPriority
		named: 'Callback queue for worker: ', self workerName
]

{ #category : #initialization }
TFCallbackQueue >> initialize [
	super initialize.
	
	semaphore := Semaphore new.
	semaphoreIndex := Smalltalk registerExternalObject: semaphore.
	callbacks := WeakSet new.
	pendingQueue := OrderedCollection new.	
	self forkCallbackProcess
]

{ #category : #initialization }
TFCallbackQueue >> initializeWorker: aWorker [

	worker := aWorker.
	self initialize
]

{ #category : #private }
TFCallbackQueue >> lookupCallback: anExternalAddress [

	^ callbacks detect: [ :each | 
		each callbackData = anExternalAddress ]
]

{ #category : #private }
TFCallbackQueue >> nextPendingCallback [
	| externalAddress |
	
	externalAddress := self primNextPendingWorkerCallback: self worker handle.
	externalAddress ifNil: [ ^ nil ].
	
	^ (TFCallbackInvocation fromHandle: externalAddress)
		worker: self worker;
		yourself
]

{ #category : #'private primitives' }
TFCallbackQueue >> primNextPendingWorkerCallback: aWorkerHandle [
	<primitive: 'primitiveReadNextWorkerCallback' module: 'PThreadedPlugin'>

	^ self primitiveFailed
]

{ #category : #operations }
TFCallbackQueue >> registerCallback: aCallback [

	callbacks add: aCallback
]

{ #category : #accessing }
TFCallbackQueue >> semaphoreIndex [

	^ semaphoreIndex
]

{ #category : #'system startup' }
TFCallbackQueue >> shutDown [

	self terminateProcess.
	callbacks removeAll.
	pendingQueue removeAll.
	
]

{ #category : #initialization }
TFCallbackQueue >> terminateProcess [
	
	callbackProcess ifNil: [ ^ self ].
	callbackProcess terminate. 
	callbackProcess := nil
]

{ #category : #accessing }
TFCallbackQueue >> worker [

	^ worker
]

{ #category : #accessing }
TFCallbackQueue >> workerName [

	^ self worker name
]
