Class {
	#name : #TFPointerType,
	#superclass : #TFBasicType,
	#category : #ThreadedFFI
}

{ #category : #reading }
TFPointerType >> readValue: anExternalAddress offset: offset [

	^ anExternalAddress pointerAt: offset
]

{ #category : #writting }
TFPointerType >> write: anExternalAddress into: targetAddress [ 

	targetAddress pointerAt: 1 put: anExternalAddress
]