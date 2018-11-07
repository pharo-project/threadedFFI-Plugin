Class {
	#name : #TFUFFIBasicTypeMarshallingTest,
	#superclass : #TFUFFITestCase,
	#category : #'ThreadedFFI-UFFI-Tests'
}

{ #category : #accessing }
TFUFFIBasicTypeMarshallingTest >> assertSignedIntsWithFunction: function [

	| return |
	return := function invokeWithArguments: { -3 . 2 }.
	self assert: return equals: -1
]

{ #category : #accessing }
TFUFFIBasicTypeMarshallingTest >> assertUnsignedIntsWithFunction: function [

	| return |
	return := function invokeWithArguments: { 3 . 2 }.
	self assert: return equals: 5
]

{ #category : #accessing }
TFUFFIBasicTypeMarshallingTest >> externalFunction: name ofType: type [

	^ TFExternalFunction
		name: name
		moduleName: self libraryPath
		definition: (TFFunctionDefinition
							parameterTypes: {type. type}
							returnType: type)
]

{ #category : #accessing }
TFUFFIBasicTypeMarshallingTest >> libraryPath [

	^ Smalltalk os isUnix ifTrue: [ 'testLibrary.so' ] ifFalse: [ 'testLibrary.dylib' ] 
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumDouble [

	| function return |
	function := self externalFunction: 'sum_double' ofType: TFBasicType double.
				
	return := function invokeWithArguments: { 3.1 . 2.7 }.
	self assert: (return between: 5.79999999 and: 5.80001)
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumFloat [

	| function return |
	function := self externalFunction: 'sum_float' ofType: TFBasicType float.
				
	return := function invokeWithArguments: { 3.1 . 2.7 }.
	self assert: (return between: 5.79999999 and: 5.80001)
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumSignedChar [

	| function |
	function := self externalFunction: 'sum_char' ofType: TFBasicType schar.
	self assertSignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumSignedInt [

	| function |
	function := self externalFunction: 'sum_int' ofType: TFBasicType sint.
	self assertSignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumSignedInt16 [

	| function |
	function := self externalFunction: 'sum_int16_t' ofType: TFBasicType sint16.
	self assertSignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumSignedInt32 [

	| function |
	function := self externalFunction: 'sum_int32_t' ofType: TFBasicType sint32.
	self assertSignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumSignedInt64 [

	| function |
	function := self externalFunction: 'sum_int64_t' ofType: TFBasicType sint64.
	self assertSignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumSignedInt8 [

	| function |
	function := self externalFunction: 'sum_int8_t' ofType: TFBasicType sint8.
	self assertSignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumSignedLong [

	| function |
	function := self externalFunction: 'sum_long' ofType: TFBasicType slong.
	self assertSignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumSignedShort [

	| function |
	function := self externalFunction: 'sum_short' ofType: TFBasicType sshort.
	self assertSignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumUnsignedChar [

	| function |
	function := self externalFunction: 'sum_uchar' ofType: TFBasicType uchar.
	self assertUnsignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumUnsignedInt [

	| function |
	function := self externalFunction: 'sum_uint' ofType: TFBasicType uint.
	self assertUnsignedIntsWithFunction: function
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumUnsignedInt16 [

	| function |
	function := self externalFunction: 'sum_uint16_t' ofType: TFBasicType uint16.
	self assertUnsignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumUnsignedInt32 [

	| function |
	function := self externalFunction: 'sum_uint32_t' ofType: TFBasicType uint32.
	self assertUnsignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumUnsignedInt64 [

	| function |
	function := self externalFunction: 'sum_uint64_t' ofType: TFBasicType uint64.
	self assertUnsignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumUnsignedInt8 [

	| function |
	function := self externalFunction: 'sum_uint8_t' ofType: TFBasicType uint8.
	self assertUnsignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumUnsignedLong [

	| function |
	function := self externalFunction: 'sum_ulong' ofType: TFBasicType ulong.
	self assertUnsignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testSumUnsignedShort [

	| function |
	function := self externalFunction: 'sum_ushort' ofType: TFBasicType ushort.
	self assertUnsignedIntsWithFunction: function.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingTest >> testUnrefPointer [

	| function holder pointerToHolder return |
	function := TFExternalFunction
		name: 'unref_pointer'
		moduleName: self libraryPath
		definition: (TFFunctionDefinition
							parameterTypes: {TFBasicType pointer}
							returnType: TFBasicType pointer).
	
	holder := ExternalAddress allocate: TFBasicType sshort byteSize.
	TFBasicType sshort write: 17 into: holder.
	
	pointerToHolder := ExternalAddress allocate: TFBasicType pointer byteSize.
	TFBasicType pointer write: holder into: pointerToHolder.
	
	return := function invokeWithArguments: { pointerToHolder }.
	self assert: return equals: holder.
	self assert: (TFBasicType sshort readValue: return) equals: 17.
]
