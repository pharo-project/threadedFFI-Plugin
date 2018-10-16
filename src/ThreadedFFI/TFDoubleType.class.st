Class {
	#name : #TFDoubleType,
	#superclass : #TFBasicType,
	#category : #ThreadedFFI
}

{ #category : #reading }
TFDoubleType >> readValue: anExternalAddress offset: offset [
	
	^ anExternalAddress doubleAt: offset
]

{ #category : #writing }
TFDoubleType >> write: aNumber into: anExternalAddress [ 

	anExternalAddress doubleAt: 1 put: aNumber
]
