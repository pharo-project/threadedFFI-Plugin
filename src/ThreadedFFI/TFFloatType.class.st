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
