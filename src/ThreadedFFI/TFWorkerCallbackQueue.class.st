"
I'm a callback queue associated to a worker.
I handle all callbacks defined in the context of a worker.
"
Class {
	#name : #TFWorkerCallbackQueue,
	#superclass : #Object,
	#instVars : [
		'worker',
		'semaphore',
		'semaphoreIndex',
		'callbacks',
		'pendingQueue',
		'callbackProcess',
		'mutex'
	],
	#classVars : [
		'UniqueInstance'
	],
	#category : #'ThreadedFFI-Worker'
}

{ #category : #'instance creation' }
TFWorkerCallbackQueue class >> new [

	self error: 'Use #on:'
]

{ #category : #'instance creation' }
TFWorkerCallbackQueue class >> on: aWorker [
	
	^ self basicNew 
		initializeWorker: aWorker;
		yourself
]

{ #category : #operations }
TFWorkerCallbackQueue >> executePendingCallbacks [
	| first |

	[ pendingQueue isEmpty ] whileFalse: [
		first := pendingQueue removeFirst.
		first getHandle isNull 
			ifFalse: [ 
				[ first execute ] 
				on: Error 
				fork: [ :e | e pass ] ] ]
]

{ #category : #operations }
TFWorkerCallbackQueue >> fillPendingQueue [
	| callbackInvocation |

	[ 
		callbackInvocation := self nextPendingCallback.
		callbackInvocation isNil ] 
	whileFalse: [ 
		pendingQueue addLast: callbackInvocation ].
]

{ #category : #initialization }
TFWorkerCallbackQueue >> forkCallbackProcess [
	
	callbackProcess ifNotNil: [ ^ self ].
	callbackProcess := [
		[ true ] whileTrue: [
			semaphore wait: 3 seconds.
			mutex critical: [ 
				self fillPendingQueue.
				self executePendingCallbacks ] ] ] 
		forkAt: Processor highIOPriority
		named: 'Callback queue for worker: ', self workerName
]

{ #category : #initialization }
TFWorkerCallbackQueue >> initialize [
	super initialize.
	
	mutex := Mutex new.
	semaphore := Semaphore new.
	semaphoreIndex := Smalltalk registerExternalObject: semaphore.
	callbacks := WeakSet new.
	pendingQueue := OrderedCollection new.	
		
	self 
		primInitializeWorker: self worker handle 
		queue: semaphoreIndex.
	self forkCallbackProcess
]

{ #category : #initialization }
TFWorkerCallbackQueue >> initializeWorker: aWorker [

	worker := aWorker.
	self initialize
]

{ #category : #private }
TFWorkerCallbackQueue >> lookupCallback: anExternalAddress [

	^ callbacks detect: [ :each | 
		each callbackData = anExternalAddress ]
]

{ #category : #private }
TFWorkerCallbackQueue >> nextPendingCallback [
	| externalAddress |
	
	externalAddress := self primNextPendingWorkerCallback: self worker handle.
	externalAddress ifNil: [ ^ nil ].
	
	^ (TFCallbackInvocation fromHandle: externalAddress)
		worker: self;
		yourself
]

{ #category : #'private primitives' }
TFWorkerCallbackQueue >> primInitializeWorker: workerHandle queue: index [
	<primitive: 'primitiveInitializeWorkerCallbackQueue' module: 'PThreadedPlugin'>

	^ self primitiveFailed
]

{ #category : #'private primitives' }
TFWorkerCallbackQueue >> primNextPendingWorkerCallback: aWorkerHandle [
	<primitive: 'primitiveReadNextWorkerCallback' module: 'PThreadedPlugin'>

	^ self primitiveFailed
]

{ #category : #operations }
TFWorkerCallbackQueue >> registerCallback: aCallback [

	callbacks add: aCallback
]

{ #category : #initialization }
TFWorkerCallbackQueue >> terminateProcess [
	
	callbackProcess ifNil: [ ^ self ].
	callbackProcess terminate. 
	callbackProcess := nil
]

{ #category : #accessing }
TFWorkerCallbackQueue >> worker [

	^ worker
]

{ #category : #accessing }
TFWorkerCallbackQueue >> workerName [

	^ self worker name
]
