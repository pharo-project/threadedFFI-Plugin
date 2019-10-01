"
I am an asynchronous call to an external function. I reference the function to call and the arguments of the call.
The function execution will happen in a separate thread, and meanwhile the current Pharo process is suspended without suspending the entire VM thread.

For this purpose, I have a semaphore that is handed out to the primitive that executes the function.
Upon the return of the primitive (i.e., when the function execution finished is scheduled), I wait at the semaphore.
When the function execution is managed and finishes, the threaded FFI plugin will signal the semaphore and the calling Pharo process will be re-scheduled to be run.
"
Class {
	#name : #TFExternalAsyncCall,
	#superclass : #Object,
	#instVars : [
		'function',
		'semaphore',
		'arguments',
		'returnHolder',
		'returnAddress',
		'parameterArray',
		'parameterAddress',
		'index'
	],
	#category : #'ThreadedFFI-Base'
}

{ #category : #'instance creation' }
TFExternalAsyncCall class >> forFunction: aTFExternalFunction [ 
	
	^ self basicNew
		function: aTFExternalFunction;
		initialize;
		yourself
]

{ #category : #'private - allocation' }
TFExternalAsyncCall >> allocateParameters [
	| paramArray |
	
	arguments ifEmpty: [ ^ nil ].
	paramArray := Array new: arguments size.
	
	function definition parameterTypes withIndexDo: [ :type :idx | |holder|
		holder := ByteArray new: type byteSize.
		holder pinInMemory.
		type write: (arguments at: idx) into: holder.
		paramArray at: idx put: holder.
	].

	^ paramArray.
]

{ #category : #'private - allocation' }
TFExternalAsyncCall >> allocateReturn [

	^ (ByteArray new: function definition returnType byteSize)
		pinInMemory;
		yourself
]

{ #category : #operations }
TFExternalAsyncCall >> cleanUp [
	self deregisterSemaphore.
	
	self 
		primitiveReleaseParameters: parameterAddress
	 	releaseReturn: returnHolder.	
	
	^ self freeArguments: parameterArray
]

{ #category : #'private - semaphore' }
TFExternalAsyncCall >> deregisterSemaphore [
	
	Smalltalk unregisterExternalObject: semaphore
]

{ #category : #operations }
TFExternalAsyncCall >> doExecuteOn: aRunner [
	
	aRunner
		executeFunction: function
		withArguments: parameterAddress
		withReturnHolder: returnAddress
		usingSemaphore: index.
	
	"I check if the semaphore is already signaled, because doing it in this way 
	is thousands of times faster than just executing the wait. 
	I think is a bug in the VM"
	semaphore isSignaled ifFalse: [ semaphore wait ].
	
	^ self readReturnValue: returnHolder
]

{ #category : #operations }
TFExternalAsyncCall >> executeOn: aRunner [
	"Performs a callout using the asynchronous threaded FFI plugin.
	 This method schedules the execution of a function in the threaded FFI plugin and 
	 then waits for its result in a semaphore.
	 When the semaphore is signaled, the result is available in an external value holder
	 from where the value is read.
	 This method contains some boilerplate code to allocate and release external 
	 value holders for the arguments and the return value."

	self prepareExecution.
	^ [ self doExecuteOn: aRunner ]
		ensure: [ self cleanUp ]
]

{ #category : #'private - allocation' }
TFExternalAsyncCall >> freeArguments: argumentsArray [
	
	argumentsArray ifNil: [ ^ self ].

	function definition parameterTypes withIndexDo: [ :type :idx |
		type freeValueIfNeeded: (argumentsArray at:idx).
	].


]

{ #category : #accessing }
TFExternalAsyncCall >> function [
	^ function
]

{ #category : #accessing }
TFExternalAsyncCall >> function: anObject [
	function := anObject
]

{ #category : #initialization }
TFExternalAsyncCall >> initialize [
	semaphore := Semaphore new.
]

{ #category : #accessing }
TFExternalAsyncCall >> parameters [
	^ arguments
]

{ #category : #accessing }
TFExternalAsyncCall >> parameters: anObject [
	arguments := anObject
]

{ #category : #operations }
TFExternalAsyncCall >> prepareExecution [
	self validateFunction.
	self validateArguments.
	
	returnHolder := self allocateReturn.
	returnAddress := ExternalAddress null.
	parameterArray := self allocateParameters.
	parameterAddress := ExternalAddress null.

	index := self registerSemaphore.

	self
		primitivePrepareParameters: parameterArray
		into: parameterAddress
		prepareReturn: returnHolder
		into: returnAddress
]

{ #category : #'private - primitives' }
TFExternalAsyncCall >> primitivePrepareParameters: aParameterArray into: aParameterAddress prepareReturn: aReturnHodler into: aReturnAddress [

	<primitive: 'primitivePrepareParametersForCall' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #'private - primitives' }
TFExternalAsyncCall >> primitiveReleaseParameters: aParameterArrayAddress releaseReturn: aReturnAddress [	

	<primitive: 'primitiveReleaseParametersForCall' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #'private - marshalling' }
TFExternalAsyncCall >> readReturnValue: aValueHolder [

	function definition returnType isVoid ifTrue: [ ^ nil ].
	^ function definition returnType readReturnValue: aValueHolder
]

{ #category : #'private - semaphore' }
TFExternalAsyncCall >> registerSemaphore [
	
	^ Smalltalk registerExternalObject: semaphore
]

{ #category : #accessing }
TFExternalAsyncCall >> semaphore [
	^ semaphore
]

{ #category : #'private - validation' }
TFExternalAsyncCall >> validateArguments [
	
	function definition parameterTypes size = arguments size
		ifFalse: [ self error: 'The number of parameters does not match the expected ones' ].
]

{ #category : #'private - validation' }
TFExternalAsyncCall >> validateFunction [
	
	function validate
]
