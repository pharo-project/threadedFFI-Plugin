"
I execute the asynchronic call into a system queue.

"
Class {
	#name : #TFExternalAsyncCallInQueue,
	#superclass : #TFExternalAsyncCall,
	#instVars : [
		'queueName'
	],
	#category : #'ThreadedFFI-Base'
}

{ #category : #'as yet unclassified' }
TFExternalAsyncCallInQueue >> forMainQueue [

	"nil will be (for now), 'main'"
	self queueName: nil
]

{ #category : #accessing }
TFExternalAsyncCallInQueue >> queueName [
	^ queueName
]

{ #category : #accessing }
TFExternalAsyncCallInQueue >> queueName: anObject [
	queueName := anObject
]

{ #category : #'private - primitive' }
TFExternalAsyncCallInQueue >> scheduleFunctionExecution: aExternalFunction withArguments: argumentsAddress withReturnHolder: returnHolderAddress usingSemaphore: semaphoreIndex [ 
	
	<primitive: 'primitivePerformCallInQueue' module: 'PThreadedPlugin'>

	self primitiveFailed
]
