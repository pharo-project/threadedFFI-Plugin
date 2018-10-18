"
I represent a float type in libffi.
I override the marshalling methods from/to C floats to pharo objects.

See my superclass for more details.
"
Class {
	#name : #TFFloatType,
	#superclass : #TFBasicType,
	#category : #ThreadedFFI
}

{ #category : #reading }
TFFloatType >> readValue: anExternalAddress offset: offset [

	^ anExternalAddress floatAt: offset
]

{ #category : #writing }
TFFloatType >> write: aNumber into: anExternalAddress [ 
	
	anExternalAddress floatAt: 1 put: aNumber
]
