Class {
	#name : #TFMainThreadRunner,
	#superclass : #TFRunner,
	#category : #'ThreadedFFI-Worker'
}

{ #category : #private }
TFMainThreadRunner >> ensureInitialized [

	handle := self workerAddress
]

{ #category : #private }
TFMainThreadRunner >> primitivePerformWorkerCall: aTFExternalFunction withArguments: argumentHolder withReturnHolder: aReturnHolder usingSemaphore: anInteger [ 
	
	<primitive: 'primitivePerformWorkerCall' module: 'PThreadedPlugin'>

	^ self primitiveFailed 
]

{ #category : #private }
TFMainThreadRunner >> workerAddress [

	^ (ExternalAddress loadSymbol: 'mainThreadWorker') pointerAt: 1
]
