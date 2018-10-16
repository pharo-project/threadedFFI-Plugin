Class {
	#name : #TFCallbackQueue,
	#superclass : #Object,
	#instVars : [
		'semaphore',
		'semaphoreIndex',
		'callbacks',
		'pendingQueue',
		'callbackProcess'
	],
	#classVars : [
		'UniqueInstance'
	],
	#category : #ThreadedFFI
}

{ #category : #handlers }
TFCallbackQueue class >> initialize [
	SessionManager default registerSystemClassNamed: self name atPriority: 70.
	self startUp: true.
]

{ #category : #handlers }
TFCallbackQueue class >> new [
	
	self error: 'You should not create instances directly'.
]

{ #category : #handlers }
TFCallbackQueue class >> startUp: resuming [
	resuming
		ifFalse: [ ^ self ].

	UniqueInstance ifNotNil: [ UniqueInstance terminateProcess ].

	UniqueInstance := self basicNew
		initialize;
		yourself
]

{ #category : #handlers }
TFCallbackQueue class >> uniqueInstance [

	^ UniqueInstance
]

{ #category : #operations }
TFCallbackQueue >> executePendingCallbacks [
	
	| first |

	[pendingQueue isEmpty] whileFalse: [
		first := pendingQueue removeFirst.
		first getHandle isNull ifFalse: [ [first execute] on:Error fork: [ :e | e pass ] ]]
]

{ #category : #operations }
TFCallbackQueue >> fillPendingQueue [
	| callbackInvocation |

	[ 
		callbackInvocation := self privNextPendingCallback.
		callbackInvocation isNil ] whileFalse: [ pendingQueue addLast: callbackInvocation ].
]

{ #category : #operations }
TFCallbackQueue >> forkCallbackProcess [

	callbackProcess ifNotNil: [ ^ self ].
	
	callbackProcess := [ 
		[ true ] whileTrue: [  
			semaphore wait: 3 seconds asDuration.
			TFCallbackQueue uniqueInstance fillPendingQueue.
			TFCallbackQueue uniqueInstance executePendingCallbacks] ] forkAt: 70.
]

{ #category : #initialization }
TFCallbackQueue >> initialize [

	semaphore := Semaphore new.
	semaphoreIndex := Smalltalk registerExternalObject: semaphore.
	callbacks := WeakSet new.
	pendingQueue := OrderedCollection new.	
		
	self primInitializeQueue: semaphoreIndex.
	
	self forkCallbackProcess.
]

{ #category : #'private - operations' }
TFCallbackQueue >> lookupCallback: anExternalAddress [

	^ callbacks detect: [ :each | each callbackData value = anExternalAddress value ]
]

{ #category : #primitives }
TFCallbackQueue >> primInitializeQueue: index [

	<primitive: 'primitiveInitializeCallbacksQueue' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #primitives }
TFCallbackQueue >> primNextPendingCallback: anExternalAddress [

	<primitive: 'primitiveReadNextCallback' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #'private - operations' }
TFCallbackQueue >> privNextPendingCallback [

	| anExternalAddress |
	anExternalAddress := ExternalAddress new.
	self primNextPendingCallback: anExternalAddress.

	anExternalAddress isNull ifTrue: [ ^ nil ].
	
	^ TFCallbackInvocation fromHandle: anExternalAddress.
	

]

{ #category : #operations }
TFCallbackQueue >> registerCallback: aCallback [

	callbacks add: aCallback
]

{ #category : #operations }
TFCallbackQueue >> terminateProcess [
	
	callbackProcess ifNotNil: [ callbackProcess terminate. callbackProcess := nil ]
]
