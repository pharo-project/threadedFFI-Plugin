Class {
	#name : #TFCallbackInvocation,
	#superclass : #FFIExternalObject,
	#instVars : [
		'worker'
	],
	#category : #'ThreadedFFI-Callbacks'
}

{ #category : #operations }
TFCallbackInvocation >> arguments [
	| parameterTypes argumentsAddress |
	
	parameterTypes := self callback parameterTypes.
	argumentsAddress := self argumentsAddress.
	
	^ parameterTypes withIndexCollect: [ :type :idx |
		type readValue: (argumentsAddress pointerAt: 1 + ((idx - 1) * Smalltalk wordSize)) ]
]

{ #category : #accessing }
TFCallbackInvocation >> argumentsAddress [

	^ TFBasicType pointer 
		readValue: handle 
		offset: 1 + (TFBasicType pointer byteSize * 2)
]

{ #category : #accessing }
TFCallbackInvocation >> callback [ 
	
	^ self worker lookupCallback: (self callbackData)
]

{ #category : #accessing }
TFCallbackInvocation >> callbackData [

	^ TFBasicType pointer readValue: handle
]

{ #category : #operations }
TFCallbackInvocation >> execute [ 
	| callback returnValue |
	
	callback := self callback.
	
	returnValue := callback frontendCallback valueWithArguments: self arguments.
	callback returnType isVoid 
		ifFalse: [ self writeReturnValue: returnValue ].

	self returnExecution
]

{ #category : #private }
TFCallbackInvocation >> primCallbackReturn: workerHandle [
	<primitive: 'primitiveWorkerCallbackReturn' module: 'PThreadedPlugin'>

	^ self primitiveFailed
]

{ #category : #operations }
TFCallbackInvocation >> returnExecution [

	self primCallbackReturn: self worker handle.
	handle beNull
]

{ #category : #accessing }
TFCallbackInvocation >> returnHolder [

	^ TFBasicType pointer readValue: handle offset: 1 + TFBasicType pointer byteSize
]

{ #category : #accessing }
TFCallbackInvocation >> worker [ 

	^ worker
]

{ #category : #accessing }
TFCallbackInvocation >> worker: aWorker [

	worker := aWorker
]

{ #category : #operations }
TFCallbackInvocation >> writeReturnValue: aValue [

	self callback returnType 
		write: aValue 
		into: self returnHolder
]
