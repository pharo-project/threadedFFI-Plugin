Class {
	#name : #TFDoubleType,
	#superclass : #TFBasicType,
	#category : #ThreadedFFI
}

{ #category : #reading }
TFDoubleType >> readValue: anExternalAddress [ 
	
	^ anExternalAddress doubleAt: 1
]

{ #category : #writing }
TFDoubleType >> write: aNumber into: anExternalAddress [ 

	anExternalAddress doubleAt: 1 put: aNumber
]
