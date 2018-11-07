Class {
	#name : #TFUFFIBasicTypeMarshallingInCallbacksTest,
	#superclass : #TFUFFITestCase,
	#category : #'ThreadedFFI-UFFI-Tests'
}

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> assertIntType: aType value: aValue [

	| callbackGotValue |
	callbackGotValue := self call: aType value: aValue.
	self assert: callbackGotValue equals: aValue.
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> assertSignedIntType: name [

	self assertIntType: name value: -65
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> assertSignedIntType: aType named: name [

	self assertIntType: name value: -65
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> assertUnsignedIntType: name [

	self assertIntType: name value: 65
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> assertUnsignedIntType: aType named: name [

	self assertIntType: name value: 65
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> call: aName type: aType value: aValue [

	| callback received |

	callback := self
		newCallbackWithSignature: { #void . aType }
		block: [ :a | received := a ].
	self
		perform: ('simple_callback_f_', aName, ':value:') asSymbol
		withArguments: { callback . aValue}.
	^ received
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> call: aName value: aValue [

	^ self call: aName type: { aName } value: aValue
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_char: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_char(void *callback, char aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_double: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_double(void *callback, double aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_float: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_float(void *callback, float aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_int16: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_int16_t(void *callback, int16 aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_int32: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_int32_t(void *callback, int32 aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_int64: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_int64_t(void *callback, int64 aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_int8: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_int8_t(void *callback, int8 aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_int: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_int(void *callback, int aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_long: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_long(void *callback, long aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_longlong: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_longlong(void *callback, longlong aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_pointer: aCallback value: aValue [ 

	^ self ffiCall: #(void simple_callback_f_ulonglong(void *aCallback, void* aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_short: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_short(void *callback, short aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_uchar: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_uchar(void *callback, uchar aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_uint16: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_uint16_t(void *callback, uint16 aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_uint32: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_uint32_t(void *callback, uint32 aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_uint64: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_uint64_t(void *callback, uint64 aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_uint8: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_uint8_t(void *callback, uint8 aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_uint: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_uint(void *callback, uint aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_ulong: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_ulong(void *callback, ulong aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_ulonglong: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_ulonglong(void *callback, ulonglong aValue))
]

{ #category : #'ffi-calls' }
TFUFFIBasicTypeMarshallingInCallbacksTest >> simple_callback_f_ushort: callback value: aValue [
	^ self ffiCall: #(void simple_callback_f_ushort(void *callback, ushort aValue))
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testDouble [

	| received |
	received := self call: 'double' value: 2.7.
	self assert: received equals: 2.7
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testFloat [

	| received |
	received := self call: 'float' value: 2.7.
	self assert: (received between: 2.6999 and: 2.7001)
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testPointer [

	| bytes received |
	[
	bytes := ExternalAddress allocate: 2 "bytes".
	received := self call: 'pointer' type: #(void* name) value: bytes.
	self assert: received getHandle equals: bytes getHandle
	] ensure: [ bytes free ]
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testSignedChar [

	self assertSignedIntType: 'char'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testSignedInt [

	self assertSignedIntType: 'int'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testSignedInt16 [

	self assertSignedIntType: 'int16'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testSignedInt32 [

	self assertSignedIntType: 'int32'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testSignedInt64 [

	self assertSignedIntType: 'int64'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testSignedInt8 [

	self assertSignedIntType: 'int8'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testSignedLong [

	self assertSignedIntType: 'long'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testSignedShort [

	self assertSignedIntType: 'short'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testUnsignedChar [

	self assertUnsignedIntType: 'uchar'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testUnsignedInt [

	self assertUnsignedIntType: 'uint'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testUnsignedInt16 [

	self assertUnsignedIntType: 'uint16'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testUnsignedInt32 [

	self assertUnsignedIntType: 'uint32'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testUnsignedInt64 [

	self assertUnsignedIntType: 'uint64'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testUnsignedInt8 [

	self assertUnsignedIntType: 'uint8'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testUnsignedLong [

	self assertUnsignedIntType: 'ulong'
]

{ #category : #tests }
TFUFFIBasicTypeMarshallingInCallbacksTest >> testUnsignedShort [

	self assertUnsignedIntType: 'ushort'
]
