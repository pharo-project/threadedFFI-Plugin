Class {
	#name : #TFOOPType,
	#superclass : #TFDerivedType,
	#category : #'ThreadedFFI-Types'
}

{ #category : #accessing }
TFOOPType >> basicType [
	
	^ TFBasicType pointer
]

{ #category : #'reading-writing' }
TFOOPType >> readValue: anExternalAddress [
	^ PointerUtils objectForOop: (self basicType readValue: anExternalAddress) asInteger
]

{ #category : #'reading-writing' }
TFOOPType >> write: anObject into: anExternalAddress [ 
	
	self basicType write: (PointerUtils oopForObject: anObject) into: anExternalAddress
]
