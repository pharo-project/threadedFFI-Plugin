"
I'm a callback queue associated to a worker.
I handle all callbacks defined in the context of a worker.
"
Class {
	#name : #TFCallbackQueue,
	#superclass : #Object,
	#instVars : [
		'semaphore',
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
TFCallbackQueue class >> initialize [

	SessionManager default
		registerSystemClassNamed: self name
		atPriority: 70.	
]

{ #category : #'instance creation' }
TFCallbackQueue class >> shutDown: inANewImageSession [

	inANewImageSession ifTrue:[
		self uniqueInstance shutDown.
		UniqueInstance := nil.
	]
]

{ #category : #'instance creation' }
TFCallbackQueue class >> startUp: inANewImageSession [

	inANewImageSession ifTrue:[
		self uniqueInstance startUp.	
	]
]

{ #category : #'instance creation' }
TFCallbackQueue class >> uniqueInstance [ 
	
	^ UniqueInstance ifNil: [ UniqueInstance := self new ]
]

{ #category : #operations }
TFCallbackQueue >> executeCallback: aCallbackInvocation [
	
	aCallbackInvocation ifNil: [ ^self ].
	aCallbackInvocation getHandle isNull ifTrue: [ ^self ].
	
	aCallbackInvocation callback: (self lookupCallback: aCallbackInvocation callbackData).
	
	[[ aCallbackInvocation execute ] 
			on: Error 
			fork: [ :e | e pass ]] fork
]

{ #category : #initialization }
TFCallbackQueue >> forkCallbackProcess [
	
	callbackProcess ifNotNil: [ ^ self ].
	callbackProcess := [
		[ true ] whileTrue: [
			semaphore wait.
			self executeCallback: self nextPendingCallback ] ] 
		forkAt: Processor highIOPriority
		named: 'Callback queue'
]

{ #category : #initialization }
TFCallbackQueue >> initialize [
	super initialize.
	
	semaphore := Semaphore new.
	callbacks := WeakSet new.
	pendingQueue := OrderedCollection new.
	self forkCallbackProcess
]

{ #category : #initializing }
TFCallbackQueue >> initializeQueue [
	
	| semaphoreIndex |
	
	semaphoreIndex := Smalltalk registerExternalObject: semaphore.
	self primitiveInitializeQueueWith: semaphoreIndex
]

{ #category : #private }
TFCallbackQueue >> lookupCallback: anExternalAddress [

	^ callbacks detect: [ :each | 
		each callbackData = anExternalAddress ]
]

{ #category : #private }
TFCallbackQueue >> nextPendingCallback [
	| externalAddress |
	
	externalAddress := self primNextPendingCallback.
	externalAddress ifNil: [ ^ nil ].
	
	^ TFCallbackInvocation fromHandle: externalAddress
]

{ #category : #'private primitives' }
TFCallbackQueue >> primNextPendingCallback [
	<primitive: 'primitiveReadNextCallback' module: 'PThreadedPlugin'>

	^ self primitiveFailed
]

{ #category : #primitives }
TFCallbackQueue >> primitiveInitializeQueueWith: anInteger [ 

	<primitive: 'primitiveInitilizeCallbacks' module: 'PThreadedPlugin'>

	^ self primitiveFailed 
]

{ #category : #operations }
TFCallbackQueue >> registerCallback: aCallback [

	callbacks add: aCallback
]

{ #category : #'system startup' }
TFCallbackQueue >> shutDown [

	self terminateProcess.
	callbacks removeAll.
	pendingQueue removeAll.
	
]

{ #category : #'system startup' }
TFCallbackQueue >> startUp [

	self initializeQueue.
	self forkCallbackProcess
]

{ #category : #initialization }
TFCallbackQueue >> terminateProcess [
	
	callbackProcess ifNil: [ ^ self ].
	callbackProcess terminate. 
	callbackProcess := nil
]
