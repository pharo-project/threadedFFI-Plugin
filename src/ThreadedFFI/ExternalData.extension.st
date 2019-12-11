Extension { #name : #ExternalData }

{ #category : #'*ThreadedFFI' }
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
