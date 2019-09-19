Extension { #name : #ExternalData }

{ #category : #'*UnifiedFFI' }
ExternalData >> + offset [ 
	"Pointer aritmetic, it allows to move the pointer as in C.
	 But obviously, it only applies to actual external addresses."
	self getHandle isExternalAddress 
		ifFalse: [ self error: 'You cannot apply pointer aritmetic to a non external address' ].
	^ self species
		fromHandle: (self getHandle + offset)
		type: type
]

{ #category : #'*UnifiedFFI' }
ExternalData >> asInteger [
	^ self getHandle asInteger
]

{ #category : #'*UnifiedFFI' }
ExternalData >> beNull [
	^ self getHandle beNull
]

{ #category : #'*UnifiedFFI' }
ExternalData >> copyFrom: start to: stop [
	^ self getHandle copyFrom: start to: stop
]

{ #category : #'*UnifiedFFI' }
ExternalData >> readString [
	self isNull ifTrue: [ ^ nil ].
	^ self fromCString
]

{ #category : #'*UnifiedFFI' }
ExternalData >> readStringUTF8 [
	"Assume that the receiver represents a C string containing UTF8 characters and convert 
	 it to a Smalltalk string.
	If the conversion fails, use the null encoding"
	| stream index char bytes |

	self isNull ifTrue: [ ^ nil ].
	
	type isPointerType ifFalse: [self error: 'External object is not a pointer type.'].
	stream := WriteStream on: ByteArray new.
	index := 1.
	[(char := handle unsignedByteAt: index) = 0 ] whileFalse: [
		stream nextPut: char.
		index := index + 1].
	^ [ ZnCharacterEncoder utf8 decodeBytes: (bytes := stream contents) ]
		on: ZnInvalidUTF8 
		do: [ bytes asString ]

]

{ #category : #'*UnifiedFFI' }
ExternalData >> value [
	^ self asInteger
]
