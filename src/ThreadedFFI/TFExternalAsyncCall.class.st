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
	| paramArray pointerSize |
	
	arguments ifEmpty: [ ^ nil ].
	pointerSize := TFBasicType pointer byteSize.
	paramArray := ByteArray new: (arguments size * pointerSize).
	
	function definition parameterTypes withIndexDo: [ :type :idx | |holder|
		holder := ExternalAddress allocate: type byteSize.
		type write: (arguments at: idx) into: holder.
		paramArray pointerAt: 1 + ((idx-1)*pointerSize) put: holder.
	].

	^ paramArray.
]

{ #category : #'private - allocation' }
TFExternalAsyncCall >> allocateReturn [
	
	^ ByteArray new: function definition returnType byteSize.
]

{ #category : #operations }
TFExternalAsyncCall >> cleanUp [
	self deregisterSemaphore.
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

	| pointerSize |
	
	argumentsArray isNil ifTrue: [ ^ self ].
	pointerSize := TFBasicType pointer byteSize.

	function definition parameterTypes withIndexDo: [ :type :idx |
		type freeValueIfNeeded: (argumentsArray pointerAt: 1 + ((idx-1)*pointerSize)).
		(argumentsArray pointerAt: 1 + ((idx-1)*pointerSize)) free.
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
	returnHolder pinInMemory.
	returnAddress := PointerUtils oopForObject: returnHolder.
	parameterArray := self allocateParameters.
	parameterArray pinInMemory.
	parameterAddress := parameterArray
		ifNil: [ ExternalAddress null ]
		ifNotNil: [ PointerUtils oopForObject: parameterArray ].
	index := self registerSemaphore
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
