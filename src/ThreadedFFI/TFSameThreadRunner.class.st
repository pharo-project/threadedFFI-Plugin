Class {
	#name : #TFSameThreadRunner,
	#superclass : #TFRunner,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'ThreadedFFI-Worker'
}

{ #category : #accessing }
TFSameThreadRunner class >> uniqueInstance [

	^ uniqueInstance ifNil: [ uniqueInstance := self basicNew initialize ]
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
