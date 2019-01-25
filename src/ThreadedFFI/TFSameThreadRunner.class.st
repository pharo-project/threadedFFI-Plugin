Class {
	#name : #TFSameThreadRunner,
	#superclass : #TFRunner,
	#category : #'ThreadedFFI-Worker'
}

{ #category : #'as yet unclassified' }
TFSameThreadRunner >> ensureInitialized [

	handle := self primitiveGetRunnerAddress.
]

{ #category : #'as yet unclassified' }
TFSameThreadRunner >> executeFunction: aTFExternalFunction withArguments: argumentHolder withReturnHolder: aReturnHolder usingSemaphore: anInteger [

	self
		primitiveInvokeFunction: aTFExternalFunction
		withArguments: argumentHolder
		returnHolder: aReturnHolder
		andSemaphoreIndex: anInteger.
]

{ #category : #executing }
TFSameThreadRunner >> primitiveGetRunnerAddress [

	<primitive: 'primitiveGetSameThreadRunnerAddress' module: 'PThreadedPlugin'>

	self primitiveFailed 	
]

{ #category : #executing }
TFSameThreadRunner >> primitiveInvokeFunction: aTFExternalFunction withArguments: argumentHolder returnHolder: aReturnHolder
andSemaphoreIndex: semaphoreIndex [
	<primitive: 'primitiveSameThreadCallout' module: 'PThreadedPlugin'>

	self primitiveFailed 	
]
