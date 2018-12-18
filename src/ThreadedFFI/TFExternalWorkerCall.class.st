Class {
	#name : #TFExternalWorkerCall,
	#superclass : #TFExternalAsyncCall,
	#category : #'ThreadedFFI-Base'
}

{ #category : #private }
TFExternalWorkerCall >> queueArray [

	^ function queue ifNotNil: [ :queue | 
		queue isMain 
			ifTrue: [ { true. nil } ]
			ifFalse: [ { false. queue handle } ] ]
]

{ #category : #'private - primitive' }
TFExternalWorkerCall >> scheduleFunctionExecution: aExternalFunction withArguments: argumentsAddress withReturnHolder: returnHolderAddress usingSemaphore: semaphoreIndex [ 
	
	^ self 
		scheduleFunctionExecution: aExternalFunction
		withArguments: argumentsAddress
		withReturnHolder: returnHolderAddress
		usingSemaphore: semaphoreIndex
		worker: self workerHandle
		queue: self queueArray
]

{ #category : #'private - primitive' }
TFExternalWorkerCall >> scheduleFunctionExecution: aExternalFunction withArguments: argumentsAddress withReturnHolder: returnHolderAddress usingSemaphore: semaphoreIndex worker: aWorkerHandle queue: anArray [

	<primitive: 'primitivePerformWorkerCall' module: 'PThreadedPlugin'>

	self primitiveFailed
]

{ #category : #private }
TFExternalWorkerCall >> workerHandle [

	^ function worker handle
]
