Class {
	#name : #PointerUtils,
	#superclass : #Object,
	#category : #'ThreadedFFI-Utils'
}

{ #category : #private }
PointerUtils class >> objectForOop: anAddressAsInteger [

	^ self primObjectForOop: anAddressAsInteger
]

{ #category : #private }
PointerUtils class >> oopForObject: anObject [

	^ ExternalAddress new
		fromInteger: (self primOopForObject: anObject);
		yourself
		 
]

{ #category : #private }
PointerUtils class >> primObjectForOop: anObject [

	"This primitive fails if the object is not pinned"

	<primitive: 'primitiveGetObjectFromAddress' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #private }
PointerUtils class >> primOopForObject: anObject [

	"This primitive fails if the object is not pinned"

	<primitive: 'primitiveGetAddressOfOOP' module: 'PThreadedPlugin'>

	anObject isPinned ifFalse: [ self error: 'Objects passed by reference should be pinned' ].

	^ self primitiveFailed	
]
