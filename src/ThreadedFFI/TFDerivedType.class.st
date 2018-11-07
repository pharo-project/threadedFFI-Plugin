Class {
	#name : #TFDerivedType,
	#superclass : #Object,
	#classVars : [
		'BOOLEAN'
	],
	#category : #ThreadedFFI
}

{ #category : #accessing }
TFDerivedType class >> boolean [
	
	^ BOOLEAN ifNil: [ BOOLEAN := TFBooleanType new ]
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
	"
	  0 = false
	~~0 = true
	"
	^ (self basicType readValue: anExternalAddress) ~~ 0
]

{ #category : #validating }
TFDerivedType >> validate [
	
	self basicType validate
]

{ #category : #'reading-writing' }
TFDerivedType >> write: anObject into: anExternalAddress [
	
	self subclassResponsibility
]
