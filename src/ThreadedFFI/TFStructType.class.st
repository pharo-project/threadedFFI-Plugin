Class {
	#name : #TFStructType,
	#superclass : #TFAbstractType,
	#instVars : [
		'members',
		'offsets',
		'targetClass'
	],
	#category : #'ThreadedFFI-Types'
}

{ #category : #'instance creation' }
TFStructType class >> finalizeResourceData: handle [

	handle isNull ifTrue: [ ^ self ].

	(self fromHandle: handle)
		free.
		
	handle beNull.
]

{ #category : #'instance creation' }
TFStructType class >> forClass: aClass withMembers: aCollectionOfMembers [
	
	^ self new
		members: aCollectionOfMembers asArray;
		targetClass: aClass;
		autoRelease;
		yourself
]

{ #category : #accessing }
TFStructType >> basicType [ 
	^ self
]

{ #category : #utils }
TFStructType >> copyFrom: from to: to size: size [ 
	"Copy from the from an externalAdress or a ByteArray or to a ByteArray or an External Address"

	<primitive: 'primitiveCopyFromTo' module: 'PThreadedPlugin'>
	self primitiveFail 
]

{ #category : #primitives }
TFStructType >> free [
	<primitive: 'primitiveFreeStruct' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #'as yet unclassified' }
TFStructType >> freeValueIfNeeded: anExternalAddress [ 
	
	"Nothing to free"
]

{ #category : #testing }
TFStructType >> isVoid [
	^ false
]

{ #category : #accessing }
TFStructType >> members [
	^ members
]

{ #category : #accessing }
TFStructType >> members: anObject [
	members := anObject
]

{ #category : #accessing }
TFStructType >> offsets [
	self validate.
	
	^ offsets
]

{ #category : #primitives }
TFStructType >> primitiveByteSize [
	<primitive: 'primitiveStructByteSize' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #primitives }
TFStructType >> primitiveInitializeStructType [
	<primitive: 'primitiveInitializeStructType' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #reading }
TFStructType >> readReturnValue: anExternalAddress [
	
	| newStruct |
	newStruct := targetClass fromHandle: (ByteArray new: (self byteSize)).
	self copyFrom: anExternalAddress to: newStruct getHandle size: self byteSize.
	^ newStruct
]

{ #category : #reading }
TFStructType >> readValue: anExternalAddress offset: anInteger [
	^ self targetClass fromHandle: anExternalAddress + (anInteger - 1)
]

{ #category : #accessing }
TFStructType >> targetClass [
	^ targetClass
]

{ #category : #accessing }
TFStructType >> targetClass: anObject [
	targetClass := anObject
]

{ #category : #validating }
TFStructType >> validate [
	self isValid
		ifTrue: [ ^ self ].

	members do: [ :m | m validate ].
	offsets := Array new: members size.
	
	self primitiveInitializeStructType.
]

{ #category : #writing }
TFStructType >> write: anExternalStructure into: anExternalAddress [

	self copyFrom: anExternalStructure getHandle to: anExternalAddress size: self byteSize
]
