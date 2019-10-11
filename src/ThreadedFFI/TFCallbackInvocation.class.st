Class {
	#name : #TFCallbackInvocation,
	#superclass : #FFIExternalObject,
	#instVars : [
		'callback'
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
	
	^ callback
]

{ #category : #accessing }
TFCallbackInvocation >> callback: aTFCallback [ 
	callback := aTFCallback
]

{ #category : #accessing }
TFCallbackInvocation >> callbackData [

	^ TFBasicType pointer readValue: handle
]

{ #category : #operations }
TFCallbackInvocation >> execute [ 
	|  returnValue |
	
	returnValue := callback frontendCallback valueWithArguments: self arguments.
	
	self isNull 
		ifTrue: [ ^ self  ].
	
	callback returnType isVoid 
		ifFalse: [ self writeReturnValue: returnValue ].

	self runner returnCallback: self
]

{ #category : #private }
TFCallbackInvocation >> primCallbackReturn [
	<primitive: 'primitiveCallbackReturn' module: 'PThreadedPlugin'>

	^ self primitiveFailed
]

{ #category : #operations }
TFCallbackInvocation >> returnExecution [

	self primCallbackReturn.
	handle beNull
]

{ #category : #accessing }
TFCallbackInvocation >> returnHolder [

	^ TFBasicType pointer readValue: handle offset: 1 + TFBasicType pointer byteSize
]

{ #category : #accessing }
TFCallbackInvocation >> runner [

	^ self callback runner
]

{ #category : #operations }
TFCallbackInvocation >> writeReturnValue: aValue [

	self callback returnType 
		write: aValue 
		into: self returnHolder
]
