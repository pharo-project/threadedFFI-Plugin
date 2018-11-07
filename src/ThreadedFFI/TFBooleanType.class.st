Class {
	#name : #TFBooleanType,
	#superclass : #TFDerivedType,
	#category : #ThreadedFFI
}

{ #category : #accessing }
TFBooleanType >> basicType [
	
	^ TFBasicType ushort
]

{ #category : #'reading-writing' }
TFBooleanType >> write: aBoolean into: aCollection [ 
	
	self basicType write: aBoolean asBit into: aCollection
]
