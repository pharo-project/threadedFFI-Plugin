Class {
	#name : #TFSameThreadRunner,
	#superclass : #TFRunner,
	#classVars : [
		'UniqueInstance'
	],
	#category : #'ThreadedFFI-Worker'
}

{ #category : #'instance creation' }
TFSameThreadRunner class >> new [

	self error: 'Use #uniqueInstance instead'
]

{ #category : #'instance creation' }
TFSameThreadRunner class >> uniqueInstance [

	^ UniqueInstance ifNil: [ UniqueInstance := self basicNew initialize ]
]

{ #category : #executing }
TFSameThreadRunner >> doInitialize [

	super doInitialize.
	handle := self primitiveGetRunnerAddress.
]

{ #category : #private }
TFSameThreadRunner >> primitiveGetRunnerAddress [

	<primitive: 'primitiveGetSameThreadRunnerAddress' module: 'PThreadedPlugin'>

	self primitiveFailed 	
]

{ #category : #private }
TFSameThreadRunner >> primitivePerformWorkerCall: aTFExternalFunction withArguments: argumentHolder withReturnHolder: aReturnHolder usingSemaphore: anInteger [ 

	<primitive: 'primitiveSameThreadCallout' module: 'PThreadedPlugin'>

	self primitiveFailed 	
]
