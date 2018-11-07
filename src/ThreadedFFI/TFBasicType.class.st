"
I am an abstract class representing a type in the C world.
I have a name and a code that corresponds to a type code in libffi.
From this information I:
 - calculate my size in memory for the current platform
 - provide marshalling from/to Pharo objets to their corresponding C representation.

My class side contains a set of accessors for well known types that are cached in class side variables.

!! Public API

- #byteSize
  returns the size in bytes
- #readValue: anExternalAddress
  reads a value of my type from an external address containing a pointer
- #readValue: anExternalAddress offset: anOffset
  reads a value of my type from an external address containing a pointer but starting reading at the given offset. Offsets are Pharo-like, 1-based
- #write: aValue into: anExternalAddress
  writes a value of my corresponding type into an external address
- #isVoid
  returns true if it is a void type
- #isValid
  returns true if the type is initialized

!! Implementation Details

At my first usage in a session, any of my instances will use this information to ask the ThreadedFFI plugin for the correct representation in the current platform.

See #validate and #primFillType.

My subclasses should redefine #readValue:offset: to provide correct type marshalling from C values to Pharo values
"
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
		'SCHAR',
		'SINT',
		'SINT16',
		'SINT32',
		'SINT64',
		'SINT8',
		'SLONG',
		'SSHORT',
		'TypeMap',
		'Types',
		'UCHAR',
		'UINT',
		'UINT16',
		'UINT32',
		'UINT64',
		'UINT8',
		'ULONG',
		'USHORT',
		'VOID'
	],
	#category : #ThreadedFFI
}

{ #category : #'instance creation' }
TFBasicType class >> createBasicTypes [

	^ { 	
			"Platform independent types"
			VOID := self newTypeName: #void code: 1.
		 	FLOAT := self newFloatTypeName: #float code: 2.
		 	DOUBLE := self newDoubleName: #double code: 3.

			UINT8 := self newIntTypeName: #uint8 code: 4 signed: false.
			UINT16 := self newIntTypeName: #uint16 code: 5 signed: false.
			UINT32 := self newIntTypeName: #uint32 code: 6 signed: false.
			UINT64 := self newIntTypeName: #uint64 code: 7 signed: false.
			
			SINT8 := self newIntTypeName: #sint8 code: 8 signed: true.
			SINT16 := self newIntTypeName: #sint16 code: 9 signed: true.
			SINT32 := self newIntTypeName: #sint32 code: 10 signed: true.
			SINT64 := self newIntTypeName: #sint64 code: 11 signed: true.

			"Aliased types, these depends of the architecture"
			POINTER := self newPointerTypeName: #pointer code: 12.

			UCHAR := self newIntTypeName: #uchar code: 13 signed: false.
			SCHAR := self newIntTypeName: #schar code: 14 signed: true.
			
			USHORT := self newIntTypeName: #ushort code: 15 signed: false.
			SSHORT := self newIntTypeName: #sshort code: 16 signed: true.

			UINT := self newIntTypeName: #uint code: 17 signed: false.
			SINT := self newIntTypeName: #sint code: 18 signed: true.

			ULONG := self newIntTypeName: #ulong code: 19 signed: false.
			SLONG := self newIntTypeName: #slong code: 20 signed: true.	
			}
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
TFBasicType class >> newDoubleName: aName code: aCode [

	^ TFDoubleType new 
		typeName: aName;
		typeCode: aCode;
		yourself
]

{ #category : #'instance creation' }
TFBasicType class >> newFloatTypeName: aName code: aCode [

	^ TFFloatType new 
		typeName: aName;
		typeCode: aCode;
		yourself
]

{ #category : #'instance creation' }
TFBasicType class >> newIntTypeName: aName code: aCode signed: signed [
	
	^ TFIntType new 
		typeName: aName;
		typeCode: aCode;
		signed: signed;
		yourself
]

{ #category : #'instance creation' }
TFBasicType class >> newPointerTypeName: aName code: aCode [

	^ TFPointerType new 
		typeName: aName;
		typeCode: aCode;
		yourself
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
TFBasicType class >> schar [
	^SCHAR
]

{ #category : #accessing }
TFBasicType class >> sint [
	^SINT
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
TFBasicType class >> slong [
	^SLONG
]

{ #category : #accessing }
TFBasicType class >> sshort [
	^SSHORT
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
TFBasicType class >> uchar [
	^UCHAR
]

{ #category : #accessing }
TFBasicType class >> uint [
	^UINT
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
TFBasicType class >> ulong [
	^ULONG
]

{ #category : #accessing }
TFBasicType class >> ushort [
	^USHORT
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

{ #category : #writing }
TFBasicType >> freeValueIfNeeded: aValue [ 
	
	"Do nothing. Basic types do not need to be free'd"
]

{ #category : #accessing }
TFBasicType >> isValid [ 

	^ handle isNull not
]

{ #category : #accessing }
TFBasicType >> isVoid [

	^ typeName = #void
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

{ #category : #reading }
TFBasicType >> readValue: anExternalAddress [

	^ self readValue: anExternalAddress offset: 1
]

{ #category : #reading }
TFBasicType >> readValue: anExternalAddress offset: offset [

	^ self subclassResponsibility
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

{ #category : #writing }
TFBasicType >> write: aNumber into: anExternalAddress [

	self subclassResponsibility
]
