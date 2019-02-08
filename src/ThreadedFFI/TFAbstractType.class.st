Class {
	#name : #TFAbstractType,
	#superclass : #FFIExternalReference,
	#category : #'ThreadedFFI-Types'
}

{ #category : #size }
TFAbstractType >> byteSize [
	self validate.
	^ self primitiveByteSize
]

{ #category : #accessing }
TFAbstractType >> isValid [ 

	^ handle isNull not
]

{ #category : #private }
TFAbstractType >> oopForObject: anObject [

	^ ExternalAddress new
		fromInteger: (self primOopForObject: anObject);
		yourself
		 
]

{ #category : #private }
TFAbstractType >> primOopForObject: anObject [

	"This primitive fails if the object is not pinned"

	<primitive: 'primitiveGetAddressOfOOP' module: 'PThreadedPlugin'>

	anObject isPinned ifFalse: [ self error: 'Objects passed by reference should be pinned' ].

	^ self primitiveFailed	
]

{ #category : #reading }
TFAbstractType >> readReturnValue: anExternalAddress [

	^ self subclassResponsibility
]

{ #category : #reading }
TFAbstractType >> readValue: anExternalAddress [

	^ self readValue: anExternalAddress offset: 1
]

{ #category : #reading }
TFAbstractType >> readValue: anExternalAddress offset: offset [

	^ self subclassResponsibility
]

{ #category : #writing }
TFAbstractType >> write: aNumber into: anExternalAddress [

	self subclassResponsibility
]
