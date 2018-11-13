Class {
	#name : #TFOOPType,
	#superclass : #TFDerivedType,
	#category : #'ThreadedFFI-Types'
}

{ #category : #accessing }
TFOOPType >> basicType [
	
	^ TFBasicType pointer
]

{ #category : #private }
TFOOPType >> oopForObject: anObject [

	^ ExternalAddress new
		fromInteger: (self primOopForObject: anObject);
		yourself
		 
]

{ #category : #private }
TFOOPType >> primObjectForOop: anObject [

	"This primitive fails if the object is not pinned"

	<primitive: 'primitiveGetObjectFromAddress' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #private }
TFOOPType >> primOopForObject: anObject [

	"This primitive fails if the object is not pinned"

	<primitive: 'primitiveGetAddressOfOOP' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #'reading-writing' }
TFOOPType >> readValue: anExternalAddress [
	^ self primObjectForOop: (self basicType readValue: anExternalAddress) asInteger
]

{ #category : #'reading-writing' }
TFOOPType >> write: anObject into: anExternalAddress [ 
	
	self basicType write: (self oopForObject: anObject) into: anExternalAddress
]
