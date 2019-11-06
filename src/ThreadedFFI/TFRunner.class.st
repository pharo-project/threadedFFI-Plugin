Class {
	#name : #TFRunner,
	#superclass : #FFIExternalReference,
	#instVars : [
		'callbackInvocationStack',
		'stackProtect',
		'exceptionHandler',
		'callbackReturnSemaphore',
		'semaphorePool'
	],
	#category : #'ThreadedFFI-Worker'
}

{ #category : #errors }
TFRunner >> cannotReturnCallbackFromOldSession: aCallbackInvocation [

	^ TFInvalidSessionCallbackReturn new
		callbackInvocation: aCallbackInvocation;
		signal
]

{ #category : #errors }
TFRunner >> cannotReturnCallbackInWrongOrder: aCallbackInvocation [

	^ TFIncorrectOrderCallbackReturn new
		callbackInvocation: aCallbackInvocation;
		previousCallbacks: (callbackInvocationStack copyUpTo: aCallbackInvocation);
		signal
]

{ #category : #executing }
TFRunner >> doInitialize [

	callbackInvocationStack := Stack new.
	stackProtect := Semaphore forMutualExclusion.
	semaphorePool :=  TFPool 
		newProvider: [ TFExternalSemaphore new ] 
		size: self semaphorePoolSize
]

{ #category : #executing }
TFRunner >> ensureInitialized [
	"Only initialize if the image has been restarted and thus I have no handle"
	self isNull ifTrue: [ self doInitialize ]
]

{ #category : #errors }
TFRunner >> exceptionHandler [

	^ exceptionHandler ifNil: [ 
		exceptionHandler := TFForkCallbackExceptionHandler new ]
]

{ #category : #errors }
TFRunner >> exceptionHandler: anExceptionHandler [ 
	
	exceptionHandler := anExceptionHandler
]

{ #category : #executing }
TFRunner >> executeCallback: aCallbackInvocation [
	"Entry point to execute a callback invocation.
	Runs the callback in a separate green thread and stack it.
	The stack gives information about the order in which callbacks should return.
	If a callback does not return in the right order, an exception is thrown.
	
	To guarantee the stack is not modified while this method runs, this method should be called from a high priority process.
	  => no callbacks should finish while this method runs."

	stackProtect critical: [ callbackInvocationStack push: aCallbackInvocation ].
	[ self handleExceptionDuring: [ aCallbackInvocation execute ] ]
		fork"At: Processor userSchedulingPriority"
]

{ #category : #executing }
TFRunner >> executeFunction: aTFExternalFunction withArguments: argumentHolder withReturnHolder: aReturnHolder usingSemaphore: anInteger [

	self ensureInitialized.

	self
		primitivePerformWorkerCall: aTFExternalFunction
		withArguments: argumentHolder
		withReturnHolder: aReturnHolder
		usingSemaphore: anInteger
]

{ #category : #errors }
TFRunner >> handleExceptionDuring: aBlock [

	self exceptionHandler handleExceptionDuring: aBlock
]

{ #category : #executing }
TFRunner >> invokeFunction: aTFExternalFunction [ 
	
	^ self invokeFunction: aTFExternalFunction withArguments: #()
]

{ #category : #executing }
TFRunner >> invokeFunction: aTFExternalFunction withArguments: aCollection [ 

	^ aTFExternalFunction newCall
		parameters: aCollection;
		executeOn: self
]

{ #category : #private }
TFRunner >> primitivePerformWorkerCall: aTFExternalFunction
		withArguments: argumentHolder
		withReturnHolder: aReturnHolder
		usingSemaphore: anInteger [
		
	^ self subclassResponsibility
]

{ #category : #executing }
TFRunner >> release [ 
	
	handle beNull.
	"If the stack is not initialized it means this worker was never used for callbacks"
	stackProtect ifNil: [ ^ self ].
	stackProtect critical: [
		callbackInvocationStack := nil ]
]

{ #category : #executing }
TFRunner >> returnCallback2: aCallbackInvocation [
	"Entry point to return a callback invocation.
	Check the callbackInvocation stack to see if the given invocation is the last one.
	If so, it can return safely.
	Otherwise, throw an exception as returning means a bug in your application.
	The user must guarantee callbacks return in the correct order"
	
	stackProtect critical: [
		callbackInvocationStack ifNil: [ 
			^ self cannotReturnCallbackFromOldSession: aCallbackInvocation ].
		(callbackInvocationStack top == aCallbackInvocation)
			ifFalse: [ ^ self cannotReturnCallbackInWrongOrder: aCallbackInvocation ].
		aCallbackInvocation returnExecution.
		callbackInvocationStack pop ]
]

{ #category : #executing }
TFRunner >> returnCallback: aCallbackInvocation [
	"Entry point to return a callback invocation.
	Check the callbackInvocation stack to see if the given invocation is the last one.
	If so, it can return safely.
	Otherwise, throw an exception as returning means a bug in your application.
	The user must guarantee callbacks return in the correct order"
	
	callbackReturnSemaphore ifNil: [ 
		callbackReturnSemaphore := Semaphore new ].

	stackProtect critical: [
		callbackInvocationStack ifNil: [ 
			^ self cannotReturnCallbackFromOldSession: aCallbackInvocation ].
		(callbackInvocationStack top == aCallbackInvocation) 
			ifTrue: [ 
				aCallbackInvocation returnExecution.
				callbackInvocationStack pop.
				[
					[ callbackReturnSemaphore isEmpty ] 
					whileFalse: [ callbackReturnSemaphore signal ]
				] valueUnpreemptively.
				^ self ] ].
		
	"failed"
	callbackReturnSemaphore wait.
	self returnCallback: aCallbackInvocation
]

{ #category : #private }
TFRunner >> semaphorePool [
	
	^ semaphorePool
]

{ #category : #private }
TFRunner >> semaphorePoolSize [

	^ 10
]
