Class {
	#name : #TFCharType,
	#superclass : #TFIntType,
	#category : #'ThreadedFFI-Types'
}

{ #category : #marshalling }
TFCharType >> emitMarshallToPrimitive: builder [
	
	builder send: #asInteger
]
