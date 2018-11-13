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
		'arguments'
	],
	#category : #ThreadedFFI
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
	
	arguments ifEmpty: [ ^ ExternalAddress null ].
	pointerSize := TFBasicType pointer byteSize.
	paramArray := ExternalAddress allocate: (arguments size * pointerSize).
	
	function definition parameterTypes withIndexDo: [ :type :idx | |holder|
		holder := ExternalAddress allocate: type byteSize.
		type write: (arguments at: idx) into: holder.
		paramArray pointerAt: 1 + ((idx-1)*pointerSize) put: holder.
	].

	^ paramArray.
]

{ #category : #'private - allocation' }
TFExternalAsyncCall >> allocateReturn [
	
	^ ExternalAddress allocate: function definition returnType byteSize.
]

{ #category : #'private - semaphore' }
TFExternalAsyncCall >> deregisterSemaphore [
	
	Smalltalk unregisterExternalObject: semaphore
]

{ #category : #operations }
TFExternalAsyncCall >> execute [
	"Performs a callout using the asynchronous threaded FFI plugin.
	This method schedules the execution of a function in the threaded FFI plugin and then waits for its result in a semaphore.
	When the semaphore is signaled, the result is available in an external value holder from where the value is read.
	
	This method contains some boilerplate code to allocate and release external value holders for the arguments and the return value."
	| index parameterArray returnHolder |

	self validateFunction.
	self validateArguments.
	
	returnHolder := self allocateReturn.
	parameterArray := self allocateParameters.
	
	index := self registerSemaphore.
	
	^ [
		self scheduleFunctionExecution: function withArguments: parameterArray withReturnHolder: returnHolder usingSemaphore: index.
		semaphore wait. 
		self readReturnValue: returnHolder
	] ensure: [ 
		self deregisterSemaphore.
		self freeReturn: returnHolder.
		self freeArguments: parameterArray] .

]

{ #category : #'private - allocation' }
TFExternalAsyncCall >> freeArguments: argumentsArray [

	| pointerSize |
	
	argumentsArray isNull ifTrue: [ ^ self ].
	pointerSize := TFBasicType pointer byteSize.

	function definition parameterTypes withIndexDo: [ :type :idx |
		type freeValueIfNeeded: (argumentsArray pointerAt: 1 + ((idx-1)*pointerSize)).
		(argumentsArray pointerAt: 1 + ((idx-1)*pointerSize)) free.
	].

	argumentsArray free.
]

{ #category : #'private - allocation' }
TFExternalAsyncCall >> freeReturn: returnHolder [

	returnHolder free.
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

{ #category : #'private - marshalling' }
TFExternalAsyncCall >> readReturnValue: aValueHolder [

	function definition returnType isVoid ifTrue: [ ^ nil ].
	^ function definition returnType readReturnValue: aValueHolder
]

{ #category : #'private - semaphore' }
TFExternalAsyncCall >> registerSemaphore [
	
	^ Smalltalk registerExternalObject: semaphore
]

{ #category : #'private - primitive' }
TFExternalAsyncCall >> scheduleFunctionExecution: aExternalFunction withArguments: argumentsAddress withReturnHolder: returnHolderAddress usingSemaphore: semaphoreIndex [ 
	
	<primitive: 'primitivePerformCall' module: 'PThreadedPlugin'>

	self primitiveFailed
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
