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

{ #category : #'instance creation' }
TFWorkerManager class >> new [ 

	^ self error: 'Use #uniqueInstances'
]

{ #category : #accessing }
TFWorkerManager class >> reset [ 
	<script>
	
	self shutDown: true
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

{ #category : #'instance creation' }
TFWorkerManager class >> uniqueInstance [ 

	^ uniqueInstance ifNil: [ uniqueInstance := super new ]
]

{ #category : #accessing }
TFWorkerManager >> defaultWorker [

	^ self workerNamed: #default
]

{ #category : #registering }
TFWorkerManager >> ensureWorkerNamed: aName [

	^ self 
		workerNamed: aName 
		ifAbsent: [ self registerWorkerName: aName ]
]

{ #category : #initialization }
TFWorkerManager >> initialize [ 

	super initialize.
	workers := IdentityDictionary new.
	self registerWorkerName: #default
]

{ #category : #registering }
TFWorkerManager >> registerWorkerName: aName [
	| worker |

	worker := TFWorker named: aName.
	workers at: aName asSymbol put: worker.
	^ worker
]

{ #category : #'system startup' }
TFWorkerManager >> shutDown [
	
	workers valuesDo: #release
]

{ #category : #registering }
TFWorkerManager >> unregisterWorker: aWorker [

	aWorker shutDown.
	workers removeKey: aWorker name asSymbol
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
