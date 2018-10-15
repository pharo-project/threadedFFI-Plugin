Class {
	#name : #TFExternalAsyncCall,
	#superclass : #Object,
	#instVars : [
		'function',
		'semaphore',
		'parameters'
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

{ #category : #'private - operations' }
TFExternalAsyncCall >> allocateParameters [
	| paramArray pointerSize |
	
	parameters size = 0 ifTrue: [ ^ ExternalAddress null ].
	pointerSize := TFBasicType pointer byteSize.
	paramArray := ExternalAddress allocate: (parameters size * pointerSize).
	
	function definition parameterTypes withIndexDo: [ :type :idx | |holder|
		holder := ExternalAddress allocate: type byteSize.
		type write: (parameters at: idx) into: holder.
		paramArray pointerAt: 1 + ((idx-1)*pointerSize) put: holder.
	].

	^ paramArray.
]

{ #category : #'private - operations' }
TFExternalAsyncCall >> allocateReturn [
	
	^ ExternalAddress allocate: function definition returnType byteSize.
]

{ #category : #'private - operations' }
TFExternalAsyncCall >> deregisterSempahore [
	
	Smalltalk unregisterExternalObject: semaphore
]

{ #category : #operations }
TFExternalAsyncCall >> execute [
	| index parameterArray returnHolder |

	self validateFunction.
	self validateParameters.
	
	returnHolder := self allocateReturn.
	parameterArray := self allocateParameters.
	
	index := self registerSemaphore. 
	
	[
		self performCall: function with: parameterArray into: returnHolder using: index.
		semaphore wait. 
		^ self readReturnValue: returnHolder
	] ensure: [ 
		self deregisterSempahore.
		self freeReturn: returnHolder.
		self freeParameters: parameterArray] .

]

{ #category : #'private - operations' }
TFExternalAsyncCall >> freeParameters: parametersArray [

	| pointerSize |
	
	parametersArray isNull ifTrue: [ ^ self ].
	pointerSize := TFBasicType pointer byteSize.

	0 to: parameters size -1 do: [ :idx | 
		(parametersArray pointerAt: (idx * pointerSize) + 1) free.
	].

	parametersArray free.
]

{ #category : #'private - operations' }
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

{ #category : #accessing }
TFExternalAsyncCall >> initialize [
	semaphore := Semaphore new.
]

{ #category : #accessing }
TFExternalAsyncCall >> parameters [
	^ parameters
]

{ #category : #accessing }
TFExternalAsyncCall >> parameters: anObject [
	parameters := anObject
]

{ #category : #'private - operations' }
TFExternalAsyncCall >> performCall: aExternalFunction with: parametersAddress into: returnHolderAddress using: semaphoreIndex [ 
	
	<primitive: 'primitivePerformCall' module: 'PThreadedPlugin'>

	self primitiveFailed
]

{ #category : #'private - operations' }
TFExternalAsyncCall >> readReturnValue: aValueHolder [

	^ function definition returnType readValue: aValueHolder
]

{ #category : #'private - operations' }
TFExternalAsyncCall >> registerSemaphore [
	
	^ Smalltalk registerExternalObject: semaphore
]

{ #category : #accessing }
TFExternalAsyncCall >> semaphore [
	^ semaphore
]

{ #category : #'private - operations' }
TFExternalAsyncCall >> validateFunction [
	
	function validate
]

{ #category : #'private - operations' }
TFExternalAsyncCall >> validateParameters [
	
	function definition parameterTypes size = parameters size
		ifFalse: [ self error: 'The number of parameters does not match the expected ones' ].
]
