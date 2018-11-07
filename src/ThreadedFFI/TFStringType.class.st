"
I represent a String type in uffi that gets marshalled to a pointer type in libffi.
I override the marshalling methods to allow reading/writing strings from/to C pointers.

See my superclass for more details.
"
Class {
	#name : #TFStringType,
	#superclass : #TFDerivedType,
	#category : #ThreadedFFI
}

{ #category : #accessing }
TFStringType >> basicType [
	
	^ TFBasicType pointer
]

{ #category : #writting }
TFStringType >> freeValueIfNeeded: aCHeapValueHolder [
	
	(aCHeapValueHolder pointerAt: 1) free
]

{ #category : #writting }
TFStringType >> readValue: anExternalAddress [

	^ (self basicType readValue: anExternalAddress) readStringUTF8
]

{ #category : #writting }
TFStringType >> write: aString into: targetAddress [

	self basicType
		write: (ExternalAddress fromString: aString utf8Encoded)
		into: targetAddress
]
