"
I represent a pointer type in libffi.
I override the marshalling methods to allow reading/writing C pointers from/to C pointers.

See my superclass for more details.
"
Class {
	#name : #TFPointerType,
	#superclass : #TFBasicType,
	#category : #'ThreadedFFI-Types'
}

{ #category : #reading }
TFPointerType >> readValue: anExternalAddress offset: offset [

	^ anExternalAddress pointerAt: offset
]

{ #category : #writting }
TFPointerType >> write: anExternalAddress into: targetAddress [ 

	| address |
	

	(anExternalAddress isKindOf: ByteArray) ifTrue: [ address := anExternalAddress]
	ifFalse: [ 

	anExternalAddress 
		ifNil: [ address := ExternalAddress null ] 
		ifNotNil: [ anExternalAddress isExternalAddress 
					ifTrue: [ address := anExternalAddress ]
					ifFalse: [ address := anExternalAddress getHandle ] ]].

	address isExternalAddress ifFalse: [
		address pinInMemory.
		address := self oopForObject: address ].
			
	targetAddress pointerAt: 1 put: address
]
