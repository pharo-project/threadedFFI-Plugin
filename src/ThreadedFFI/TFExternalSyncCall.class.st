Class {
	#name : #TFExternalSyncCall,
	#superclass : #Object,
	#instVars : [
		'function',
		'semaphore',
		'arguments'
	],
	#category : #'ThreadedFFI-Base'
}

{ #category : #'instance creation' }
TFExternalSyncCall class >> forFunction: aTFExternalFunction [ 
	
	^ self basicNew
		function: aTFExternalFunction;
		initialize;
		yourself
]

{ #category : #'private - allocation' }
TFExternalSyncCall >> allocateParameters [
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
TFExternalSyncCall >> allocateParameters: args [
	| paramArray pointerSize |
	
	args ifEmpty: [ ^ ExternalAddress null ].
	pointerSize := TFBasicType pointer byteSize.
	paramArray := ExternalAddress allocate: (args size * pointerSize).
	
	function definition parameterTypes withIndexDo: [ :type :idx | |holder|
		holder := ExternalAddress allocate: type byteSize.
		type write: (args at: idx) into: holder.
		paramArray pointerAt: 1 + ((idx-1)*pointerSize) put: holder.
	].

	^ paramArray.
]

{ #category : #'private - allocation' }
TFExternalSyncCall >> allocateReturn [
	
	^ ExternalAddress allocate: function definition returnType byteSize.
]

{ #category : #'private - primitive' }
TFExternalSyncCall >> callFunctionExecution: aExternalFunction withArguments: argumentsAddress withReturnHolder: returnHolderAddress [
	
	<primitive: 'primitivePerformSyncCall' module: 'PThreadedPlugin'>

	self primitiveFailed
]

{ #category : #'private - primitive' }
TFExternalSyncCall >> callFunctionExecution: aExternalFunction withArguments: argumentsAddress withReturnHolder: returnHolderAddress usingSemaphore: semaphoreIndex [ 
	
	<primitive: 'primitivePerformSyncCall' module: 'PThreadedPlugin'>

	self primitiveFailed
]

{ #category : #'private - semaphore' }
TFExternalSyncCall >> deregisterSemaphore [
	
	Smalltalk unregisterExternalObject: semaphore
]

{ #category : #operations }
TFExternalSyncCall >> execute [
	"Performs a callout using the asynchronous threaded FFI plugin.
	This method schedules the execution of a function in the threaded FFI plugin and then waits for its result in a semaphore.
	When the semaphore is signaled, the result is available in an external value holder from where the value is read.
	
	This method contains some boilerplate code to allocate and release external value holders for the arguments and the return value."
	| index parameterArray returnHolder |

	"self validateFunction."
	"self validateArguments."
	
	returnHolder := self allocateReturn.
	parameterArray := self allocateParameters.
	
	^ [
		self callFunctionExecution: function withArguments: parameterArray withReturnHolder: returnHolder.
		self readReturnValue: returnHolder
	] ensure: [ 
		"self freeReturn: returnHolder."
		"self freeArguments: parameterArray"] .

]

{ #category : #operations }
TFExternalSyncCall >> executeWithArgs: args [
	"Performs a callout using the asynchronous threaded FFI plugin.
	This method schedules the execution of a function in the threaded FFI plugin and then waits for its result in a semaphore.
	When the semaphore is signaled, the result is available in an external value holder from where the value is read.
	
	This method contains some boilerplate code to allocate and release external value holders for the arguments and the return value."
	| index parameterArray returnHolder |

	"self validateFunction."
	"self validateArguments."
	
	returnHolder := self allocateReturn.
	parameterArray := self allocateParameters: args.
	
	^ [
		self callFunctionExecution: function withArguments: parameterArray withReturnHolder: returnHolder.
		self readReturnValue: returnHolder
	] ensure: [ 
		"self freeReturn: returnHolder."
		"self freeArguments: parameterArray"] .

]

{ #category : #'private - allocation' }
TFExternalSyncCall >> freeArguments: argumentsArray [

	| pointerSize |
	
	argumentsArray isNull ifTrue: [ ^ self ].
	pointerSize := TFBasicType pointer byteSize.

	0 to: arguments size -1 do: [ :idx | 
		(argumentsArray pointerAt: (idx * pointerSize) + 1) free.
	].

	argumentsArray free.
]

{ #category : #'private - allocation' }
TFExternalSyncCall >> freeReturn: returnHolder [

	returnHolder free.
]

{ #category : #accessing }
TFExternalSyncCall >> function [
	^ function
]

{ #category : #accessing }
TFExternalSyncCall >> function: anObject [
	function := anObject
]

{ #category : #initialization }
TFExternalSyncCall >> initialize [
	semaphore := Semaphore new.
]

{ #category : #accessing }
TFExternalSyncCall >> parameters [
	^ arguments
]

{ #category : #accessing }
TFExternalSyncCall >> parameters: anObject [
	arguments := anObject
]

{ #category : #'private - marshalling' }
TFExternalSyncCall >> readReturnValue: aValueHolder [

	^ function definition returnType readValue: aValueHolder
]

{ #category : #'private - semaphore' }
TFExternalSyncCall >> registerSemaphore [
	
	^ Smalltalk registerExternalObject: semaphore
]

{ #category : #'private - primitive' }
TFExternalSyncCall >> scheduleFunctionExecution: aExternalFunction withArguments: argumentsAddress withReturnHolder: returnHolderAddress usingSemaphore: semaphoreIndex [ 
	
	<primitive: 'primitivePerformCall' module: 'PThreadedPlugin'>

	self primitiveFailed
]

{ #category : #accessing }
TFExternalSyncCall >> semaphore [
	^ semaphore
]

{ #category : #'private - validation' }
TFExternalSyncCall >> validateArguments [
	
	function definition parameterTypes size = arguments size
		ifFalse: [ self error: 'The number of parameters does not match the expected ones' ].
]

{ #category : #'private - validation' }
TFExternalSyncCall >> validateFunction [
	
	function validate
]
