"
I represent a String type in uffi that gets marshalled to a pointer type in libffi.
I override the marshalling methods to allow reading/writing strings from/to C pointers.

See my superclass for more details.
"
Class {
	#name : #TFStringType,
	#superclass : #TFDerivedType,
	#classVars : [
		'AllocatedStrings'
	],
	#category : #'ThreadedFFI-Types'
}

{ #category : #writting }
TFStringType >> allocateString: aString [
	
	| anExternalAddress |
	
	anExternalAddress := (ExternalAddress fromString: aString utf8Encoded).
	self allocatedStrings add: anExternalAddress.
	^ anExternalAddress 
]

{ #category : #'as yet unclassified' }
TFStringType >> allocatedStrings [

	^ AllocatedStrings ifNil: [ AllocatedStrings := Set new ]
]

{ #category : #accessing }
TFStringType >> basicType [
	
	^ TFBasicType pointer
]

{ #category : #writting }
TFStringType >> freeValueIfNeeded: aCHeapValueHolder [
	
	| pointer |
	pointer := aCHeapValueHolder pointerAt: 1.
	
	(self allocatedStrings includes: pointer) ifTrue: [ 
		self allocatedStrings remove: pointer.
		pointer free.]
	
]

{ #category : #writting }
TFStringType >> readValue: anExternalAddress [

	^ (self basicType readValue: anExternalAddress) readStringUTF8
]

{ #category : #writting }
TFStringType >> write: aStringOrExternalAddress into: targetAddress [

	"If the argument is a aString I have to allocate it and later free it"
	| anAddress |
	anAddress := aStringOrExternalAddress isString ifTrue: [ self allocateString: aStringOrExternalAddress ] ifFalse: [ aStringOrExternalAddress ].
	
	self basicType
		write: anAddress
		into: targetAddress
]
