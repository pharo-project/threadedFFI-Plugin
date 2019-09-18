Class {
	#name : #TFMainThreadRunner,
	#superclass : #TFRunner,
	#classVars : [
		'MainThreadHandle'
	],
	#category : #'ThreadedFFI-Worker'
}

{ #category : #private }
TFMainThreadRunner >> doInitialize [
	
	super doInitialize.
	MainThreadHandle := self workerAddress.
	handle := MainThreadHandle
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
