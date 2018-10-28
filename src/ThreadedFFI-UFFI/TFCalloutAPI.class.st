Class {
	#name : #TFCalloutAPI,
	#superclass : #FFICalloutAPI,
	#category : #'ThreadedFFI-UFFI'
}

{ #category : #action }
TFCalloutAPI >> newBuilder [

	^ TFCalloutMethodBuilder calloutAPI: self
]
