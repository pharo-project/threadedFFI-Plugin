Class {
	#name : #TFCallback,
	#superclass : #FFIExternalReference,
	#instVars : [
		'callbackData',
		'parameterHandlers',
		'returnTypeHandler',
		'parameterTypes',
		'returnType',
		'frontendCallback'
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
TFCallback class >> forCallback: aCallback parameters: parameterTypes returnType: returnType [

	^ self new
		frontendCallback: aCallback;
		parameterTypes: parameterTypes;
		returnType: returnType;
		autoRelease;
		register;
		yourself
]

{ #category : #accessing }
TFCallback >> callbackData [
	^ callbackData
]

{ #category : #accessing }
TFCallback >> callbackData: anObject [
	callbackData := anObject
]

{ #category : #accessing }
TFCallback >> frontendCallback [

	^ frontendCallback
]

{ #category : #accessing }
TFCallback >> frontendCallback: anObject [
	frontendCallback := anObject
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

{ #category : #'private operations' }
TFCallback >> primRegister: workerHandle [
	<primitive: 'primitiveRegisterWorkerCallback' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #'private operations' }
TFCallback >> primUnregister: workerHandle [
	<primitive: 'primitiveUnregisterWorkerCallback' module: 'PThreadedPlugin'>

	^ self primitiveFailed
]

{ #category : #registering }
TFCallback >> register [
	
	handle isNull ifFalse: [ ^ self error: 'Callback already registered' ].
	self validateTypes.
	self primRegister: self workerHandle.
	self registerCallback: self.
]

{ #category : #registering }
TFCallback >> registerCallback: aCallback [

	^ self worker registerCallback: aCallback
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

{ #category : #registering }
TFCallback >> unregister [
	
	handle isNull ifTrue: [ ^ self ].
	self primUnregister: self workerHandle.
	
	handle beNull.
	callbackData beNull.

]

{ #category : #'private operations' }
TFCallback >> validateTypes [

	parameterTypes do: [ :each | each validate ].
	returnType validate.

	parameterHandlers := parameterTypes collect: [ :e | e basicType ] as: Array.
	returnTypeHandler := returnType basicType.
]

{ #category : #'private accessing' }
TFCallback >> worker [

	^ self frontendCallback worker
]

{ #category : #'private accessing' }
TFCallback >> workerHandle [

	^ self worker handle
]
