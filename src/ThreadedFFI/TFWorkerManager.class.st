"
I manage the registration/unregistration of workers for the threaded ffi system.

calling #registerWorkerName: will create and register a worker associated with a name. 

Be careful, since a worker has its equivallent on VM side, this is not a free action and can impact in your system.
"
Class {
	#name : #TFWorkerManager,
	#superclass : #Object,
	#instVars : [
		'workers'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'ThreadedFFI-Worker'
}

{ #category : #'class initialization' }
TFWorkerManager class >> initialize [

	SessionManager default
		registerSystemClassNamed: self name 
		atPriority: 70.
	self startUp: true
]

{ #category : #accessing }
TFWorkerManager class >> new [ 

	^ self error: 'Use #uniqueInstances'
]

{ #category : #'class initialization' }
TFWorkerManager class >> shutDown: quitting [
	
	quitting ifFalse: [ ^ self ].
	uniqueInstance ifNil: [ ^ self  ].

	uniqueInstance shutDown.
	uniqueInstance := nil
]

{ #category : #'class initialization' }
TFWorkerManager class >> startUp: resuming [
	"In general, this should not be necessary, but we make sure everything is clean when started."
	
	resuming ifFalse: [ ^ self ].
	self shutDown: true
]

{ #category : #accessing }
TFWorkerManager class >> uniqueInstance [ 

	^ uniqueInstance ifNil: [ uniqueInstance := super new ]
]

{ #category : #accessing }
TFWorkerManager >> defaultWorker [

	^ self workerNamed: #default
]

{ #category : #initialization }
TFWorkerManager >> initialize [ 

	super initialize.
	workers := IdentityDictionary new.
	self registerWorkerName: #default
]

{ #category : #private }
TFWorkerManager >> primRegisterWorker: aName [
	<primitive: #primitiveRegisterWorker module: #PThreadedPlugin>
	
	^ self primitiveFailed
]

{ #category : #private }
TFWorkerManager >> primUnregisterWorker: aName [
	<primitive: #primitiveUnregisterWorker module: #PThreadedPlugin>
	
	^ self primitiveFailed
]

{ #category : #registering }
TFWorkerManager >> registerWorkerName: aName [
	| worker handle |

	handle := self primRegisterWorker: aName asString.
	worker := TFWorker 
		newHandle: handle
		name: aName.
	workers at: aName asSymbol put: worker.
	^ worker
]

{ #category : #'system startup' }
TFWorkerManager >> shutDown [
	
	workers valuesDo: #shutDown
]

{ #category : #registering }
TFWorkerManager >> unregisterWorker: aWorker [

	self primUnregisterWorker: aWorker handle.
	workers remove: aWorker
]

{ #category : #accessing }
TFWorkerManager >> workerNamed: aSymbol [

	^ workers at: aSymbol
]

{ #category : #accessing }
TFWorkerManager >> workerNamed: aSymbol ifAbsent: aBlock [

	^ workers 
		at: aSymbol
		ifAbsent: aBlock
]
