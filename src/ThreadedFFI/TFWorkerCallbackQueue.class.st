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
		'callbackProcess'
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
TFWorkerCallbackQueue >> executeCallback: aCallback [
	
	aCallback getHandle isNull ifFalse: [ 
		[ [ aCallback execute ] 
			on: Error 
			fork: [ :e | e pass ] ] fork ]
]

{ #category : #operations }
TFWorkerCallbackQueue >> executePendingCallbacks [
	| first |

	[ pendingQueue isEmpty ] whileFalse: [
		first := pendingQueue removeFirst.
		first getHandle isNull ifFalse: [ 
			[[ first execute ] 
			on: Error 
			fork: [ :e | e pass ] ] fork ] ]
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
			semaphore wait.
			self executeCallback: self nextPendingCallback ] ] 
		forkAt: Processor highIOPriority
		named: 'Callback queue for worker: ', self workerName
]

{ #category : #initialization }
TFWorkerCallbackQueue >> initialize [
	super initialize.
	
	semaphore := Semaphore new.
	semaphoreIndex := Smalltalk registerExternalObject: semaphore.
	callbacks := WeakSet new.
	pendingQueue := OrderedCollection new.	
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
		worker: self worker;
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

{ #category : #accessing }
TFWorkerCallbackQueue >> semaphoreIndex [

	^ semaphoreIndex
]

{ #category : #'system startup' }
TFWorkerCallbackQueue >> shutDown [

	self terminateProcess.
	callbacks removeAll.
	pendingQueue removeAll.
	
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
