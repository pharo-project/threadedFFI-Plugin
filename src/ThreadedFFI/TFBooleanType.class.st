Class {
	#name : #TFBooleanType,
	#superclass : #TFDerivedType,
	#category : #'ThreadedFFI-Types'
}

{ #category : #accessing }
TFBooleanType >> basicType [
	
	^ TFBasicType uint8
]

{ #category : #'reading-writing' }
TFBooleanType >> readValue: anExternalAddress [
	"
	  0 = false
	~~0 = true
	"
	^ (self basicType readValue: anExternalAddress) ~~ 0
]

{ #category : #'reading-writing' }
TFBooleanType >> write: aBoolean into: aCollection [ 
	
	self basicType write: aBoolean asBit into: aCollection
]
