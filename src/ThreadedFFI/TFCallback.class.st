Class {
	#name : #TFCallback,
	#superclass : #FFIExternalReference,
	#instVars : [
		'callbackData',
		'parameterHandlers',
		'returnTypeHandler',
		'parameterTypes',
		'returnType',
		'block'
	],
	#category : #'ThreadedFFI-Callbacks'
}

{ #category : #'as yet unclassified' }
TFCallback class >> finalizeResourceData: anArray [

	(self fromHandle: anArray first)
		callbackData: anArray second;
	 	unregister
]

{ #category : #'as yet unclassified' }
TFCallback class >> forBlock: aBlock parameters: parameterTypes returnType: returnType [

	^ self new
		block: aBlock;
		parameterTypes: parameterTypes;
		returnType: returnType;
		autoRelease;
		register;
		yourself
]

{ #category : #accessing }
TFCallback >> block [
	^ block
]

{ #category : #accessing }
TFCallback >> block: anObject [
	block := anObject
]

{ #category : #accessing }
TFCallback >> callbackData [
	^ callbackData
]

{ #category : #accessing }
TFCallback >> callbackData: anObject [
	callbackData := anObject
]

{ #category : #initialization }
TFCallback >> initialize [
	super initialize.
	callbackData := ExternalAddress new.
	parameterHandlers := #()
]

{ #category : #accessing }
TFCallback >> parameterTypes [
	^ parameterTypes
]

{ #category : #accessing }
TFCallback >> parameterTypes: anObject [
	parameterTypes := anObject
]

{ #category : #'private - operations' }
TFCallback >> primRegister [

	<primitive: 'primitiveRegisterCallback' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #'private - operations' }
TFCallback >> primUnregister [

	<primitive: 'primitiveUnregisterCallback' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #operations }
TFCallback >> register [
	
	handle isNull ifFalse: [ ^ self error: 'Callback already registered' ].
	self validateTypes.
	self primRegister.
	TFCallbackQueue uniqueInstance registerCallback: self.
]

{ #category : #accessing }
TFCallback >> resourceData [
	^ { self getHandle. self callbackData}
]

{ #category : #accessing }
TFCallback >> returnType [
	^ returnType
]

{ #category : #accessing }
TFCallback >> returnType: anObject [
	returnType := anObject
]

{ #category : #accessing }
TFCallback >> thunk [
	^ self getHandle 
]

{ #category : #operations }
TFCallback >> unregister [
	
	handle isNull ifTrue: [ ^ self ].
	self primUnregister.
	
	handle beNull.
	callbackData beNull.

]

{ #category : #'private - operations' }
TFCallback >> validateTypes [

	parameterTypes do: [ :each | each validate ].
	returnType validate.

	parameterHandlers := parameterTypes collect: [ :e | e basicType ] as: Array.
	returnTypeHandler := returnType basicType.
]
