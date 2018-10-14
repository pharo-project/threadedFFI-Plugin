Class {
	#name : #TFIntType,
	#superclass : #TFBasicType,
	#instVars : [
		'signed'
	],
	#category : #ThreadedFFI
}

{ #category : #reading }
TFIntType >> readValue: anExternalAddress [ 
	
	^ anExternalAddress integerAt: 1 size: self byteSize signed: signed
]

{ #category : #accessing }
TFIntType >> signed [
	^ signed
]

{ #category : #accessing }
TFIntType >> signed: anObject [
	signed := anObject
]
