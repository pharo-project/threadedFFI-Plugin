"
I represent the callback invocation.
I have information about the activation of a given callback.
"
Class {
	#name : #TFCallbackInvocation,
	#superclass : #FFIExternalObject,
	#instVars : [
		'callback',
		'readyToReturn'
	],
	#category : #'ThreadedFFI-Callbacks'
}

{ #category : #operations }
TFCallbackInvocation >> arguments [
	| parameterTypes argumentsAddress |
	
	parameterTypes := self callback parameterTypes.
	argumentsAddress := self argumentsAddress.
	
	^ parameterTypes withIndexCollect: [ :type :idx |
		type callbackReadValue: (argumentsAddress pointerAt: 1 + ((idx - 1) * Smalltalk wordSize)) ]
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

	^ TFBasicType pointer callbackReadValue: handle
]

{ #category : #operations }
TFCallbackInvocation >> execute [ 

	self executeThen: [ 
		self runner returnCallback: self ]
]

{ #category : #operations }
TFCallbackInvocation >> executeThen: aBlock [
	"Do not make the return here, instead, execute a block that can handle the callback queue to return  	in the right moment"
	| returnValue transformedArguments |

	transformedArguments := [ self arguments 
		with: callback parameterTypes 
		collect: [ :anArgument :aType | aType marshallFromPrimitive: anArgument ] ] 
	on: Exception 
	fork: [ :e | e debug ] 
	return: [ self arguments ].

	[ returnValue := callback frontendCallback valueWithArguments: transformedArguments ] 
	ensure: [
		readyToReturn := true.

		returnValue := callback returnType marshallToPrimitive: (callback isSuccess 
			ifTrue: [ returnValue ]
			ifFalse: [ callback frontendCallback returnOnError ]).

		self isNull ifFalse: [ 
			callback returnType isVoid 
				ifFalse: [ self writeReturnValue: returnValue ].

		aBlock value ] ]
]

{ #category : #initialization }
TFCallbackInvocation >> initialize [

	super initialize.
	readyToReturn := false
]

{ #category : #testing }
TFCallbackInvocation >> isReadyToReturn [

	^ readyToReturn
]

{ #category : #private }
TFCallbackInvocation >> primCallbackReturn [
	<primitive: 'primitiveCallbackReturn'>

	"It returns true if the callback can return, and false if the order is not correct and should
 	retry later"
	
	^ self primitiveFailed
]

{ #category : #operations }
TFCallbackInvocation >> returnExecution [

	"It returns true if the callback can return, and false if the order is not correct and should retry later"

	^ self primCallbackReturn
		ifTrue: [ handle beNull. true ]
		ifFalse: [ false ]

]

{ #category : #accessing }
TFCallbackInvocation >> returnHolder [

	^ TFBasicType pointer 
		readValue: handle 
		offset: 1 + TFBasicType pointer byteSize
]

{ #category : #accessing }
TFCallbackInvocation >> runner [

	^ self callback runner
]

{ #category : #operations }
TFCallbackInvocation >> writeReturnValue: aValue [

	self callback returnType 
		callbackWrite: aValue 
		into: self returnHolder
]
