Class {
	#name : #TFBasicType,
	#superclass : #FFIExternalReference,
	#instVars : [
		'typeName',
		'typeCode'
	],
	#classVars : [
		'DOUBLE',
		'FLOAT',
		'POINTER',
		'SINT16',
		'SINT32',
		'SINT64',
		'SINT8',
		'TypeMap',
		'Types',
		'UINT16',
		'UINT32',
		'UINT64',
		'UINT8',
		'VOID'
	],
	#category : #ThreadedFFI
}

{ #category : #'instance creation' }
TFBasicType class >> createBasicTypes [

	^ { 	VOID := self newTypeName: #void code: 1.
		 	FLOAT := self newTypeName: #float code: 2.
		 	DOUBLE := self newTypeName: #double code: 3.

			UINT8 := self newTypeName: #uint8 code: 4.
			UINT16 := self newTypeName: #uint16 code: 5.
			UINT32 := self newTypeName: #uint32 code: 6.
			UINT64 := self newTypeName: #uint64 code: 7.
			
			SINT8 := self newTypeName: #sint8 code: 8.
			SINT16 := self newTypeName: #sint16 code: 9.
			SINT32 := self newTypeName: #sint32 code: 10.
			SINT64 := self newTypeName: #sint64 code: 11.
			
			POINTER := self newTypeName: #pointer code: 12. }
]

{ #category : #accessing }
TFBasicType class >> double [ 
	^ DOUBLE
]

{ #category : #accessing }
TFBasicType class >> float [ 
	^ FLOAT
]

{ #category : #'instance creation' }
TFBasicType class >> initialize [ 	
	
	Types := self createBasicTypes.
	TypeMap := (Types collect: [ :t | t typeName -> t ]) asDictionary.
]

{ #category : #'instance creation' }
TFBasicType class >> newTypeName: aName code: aCode [
	
	^ self new 
		typeName: aName;
		typeCode: aCode;
		yourself
]

{ #category : #accessing }
TFBasicType class >> pointer [ 
	^ POINTER
]

{ #category : #accessing }
TFBasicType class >> sint16 [ 
	^ SINT16
]

{ #category : #accessing }
TFBasicType class >> sint32 [ 
	^ SINT32
]

{ #category : #accessing }
TFBasicType class >> sint64 [ 
	^ SINT64
]

{ #category : #accessing }
TFBasicType class >> sint8 [ 
	^ SINT8
]

{ #category : #accessing }
TFBasicType class >> typemap [ 
	^ TypeMap
]

{ #category : #accessing }
TFBasicType class >> types [ 
	^ Types
]

{ #category : #accessing }
TFBasicType class >> uint16 [ 
	^ UINT16
]

{ #category : #accessing }
TFBasicType class >> uint32 [ 
	^ UINT32
]

{ #category : #accessing }
TFBasicType class >> uint64 [ 
	^ UINT64
]

{ #category : #accessing }
TFBasicType class >> uint8 [ 
	^ UINT8
]

{ #category : #accessing }
TFBasicType class >> void [ 
	^ VOID
]

{ #category : #size }
TFBasicType >> byteSize [
	self validate.
	^ self primByteSize
]

{ #category : #accessing }
TFBasicType >> isValid [ 

	^ handle isNull not
]

{ #category : #primitives }
TFBasicType >> primByteSize [
	<primitive: 'primitiveTypeByteSize' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #primitives }
TFBasicType >> primFillType [
	<primitive: 'primitiveFillBasicType' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]

{ #category : #printing }
TFBasicType >> printOn: aStream [
	super printOn: aStream.
	aStream 
		nextPut: $[;
		print: typeName;
		space;
		print: typeCode;
		nextPut: $]
]

{ #category : #accessing }
TFBasicType >> typeCode [
	^ typeCode
]

{ #category : #accessing }
TFBasicType >> typeCode: anObject [
	typeCode := anObject
]

{ #category : #accessing }
TFBasicType >> typeName [
	^ typeName
]

{ #category : #accessing }
TFBasicType >> typeName: anObject [
	typeName := anObject
]

{ #category : #accessing }
TFBasicType >> validate [ 
	
	self isValid ifFalse: [ self primFillType ]
]
