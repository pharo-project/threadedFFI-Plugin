Class {
	#name : #FFIConst,
	#superclass : #FFIExternalType,
	#instVars : [
		'value',
		'type'
	],
	#category : #'UnifiedFFI-Types'
}

{ #category : #'instance creation' }
FFIConst class >> value: aValue [
	^ self new value: aValue
]

{ #category : #'instance creation' }
FFIConst class >> value: anObject type: anExternalType [
	^ self new 
		value: anObject;
		type: anExternalType;
		yourself
]

{ #category : #'emitting code' }
FFIConst >> emitArgument: aBuilder context: aContext [ 
	aBuilder pushLiteral: self value
]

{ #category : #'emitting code' }
FFIConst >> emitReturn: aBuilder resultTempVar: resultVar context: aContext [ 
	self error: 'Literals cannot be used as return'
]

{ #category : #'emitting code' }
FFIConst >> emitReturnArgument: builder context: aContext [
	"Nothing to do here"
]

{ #category : #accessing }
FFIConst >> externalType [ 

	^ self type externalType
]

{ #category : #accessing }
FFIConst >> externalTypeAlignment [

	^ self externalType externalTypeAlignment
]

{ #category : #accessing }
FFIConst >> externalTypeSize [

	^ self externalType byteSize
]

{ #category : #accessing }
FFIConst >> loader [ 
	^ self
]

{ #category : #accessing }
FFIConst >> pointerArity: additionalArity [
	additionalArity > 0 ifTrue: [ self error: 'passing pointer to constant' ]
]

{ #category : #'stack parameter classification' }
FFIConst >> stackValueParameterClass [
	^ value isFloat ifTrue: [#float] ifFalse: [#integer]

]

{ #category : #accessing }
FFIConst >> type [
	^ type
]

{ #category : #accessing }
FFIConst >> type: anObject [
	type := anObject
]

{ #category : #accessing }
FFIConst >> value [
	^ value
]

{ #category : #accessing }
FFIConst >> value: anObject [
	value := anObject
]
