Class {
	#name : #TFSameThreadRunner,
	#superclass : #TFRunner,
	#category : #'ThreadedFFI-Worker'
}

{ #category : #executing }
TFSameThreadRunner >> ensureInitialized [

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
