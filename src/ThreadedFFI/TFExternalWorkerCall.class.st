Class {
	#name : #TFExternalWorkerCall,
	#superclass : #TFExternalAsyncCall,
	#instVars : [
		'workerHandle'
	],
	#category : #'ThreadedFFI-Base'
}

{ #category : #'private - primitive' }
TFExternalWorkerCall >> scheduleFunctionExecution: aExternalFunction withArguments: argumentsAddress withReturnHolder: returnHolderAddress usingSemaphore: semaphoreIndex [ 
	
	<primitive: 'primitivePerformWorkerCall' module: 'PThreadedPlugin'>

	self primitiveFailed
]

{ #category : #accessing }
TFExternalWorkerCall >> workerHandle [

	^ workerHandle
]

{ #category : #accessing }
TFExternalWorkerCall >> workerHandle: anExternalAddress [

	workerHandle := anExternalAddress
]
