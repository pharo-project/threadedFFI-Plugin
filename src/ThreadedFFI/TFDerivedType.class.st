Class {
	#name : #TFDerivedType,
	#superclass : #Object,
	#classVars : [
		'BOOLEAN',
		'STRING'
	],
	#category : #ThreadedFFI
}

{ #category : #accessing }
TFDerivedType class >> boolean [
	
	^ BOOLEAN ifNil: [ BOOLEAN := TFBooleanType new ]
]

{ #category : #accessing }
TFDerivedType class >> string [
	
	^ STRING ifNil: [ STRING := TFStringType new ]
]

{ #category : #accessing }
TFDerivedType >> basicType [
	
	^ self subclassResponsibility
]

{ #category : #accessing }
TFDerivedType >> byteSize [
	
	^ self basicType byteSize
]

{ #category : #freeing }
TFDerivedType >> freeValueIfNeeded: aCHeapValueHolder [ 
	
	"Hook into me if you want to free some value sent previously to a C function"
]

{ #category : #accessing }
TFDerivedType >> getHandle [
	
	^ self basicType getHandle
]

{ #category : #'reading-writing' }
TFDerivedType >> readValue: anExternalAddress [
	
	self subclassResponsibility
]

{ #category : #validating }
TFDerivedType >> validate [
	
	self basicType validate
]

{ #category : #'reading-writing' }
TFDerivedType >> write: anObject into: anExternalAddress [
	
	self basicType write: anObject into: anExternalAddress
]
