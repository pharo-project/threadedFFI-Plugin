Class {
	#name : #TFCalloutAPI,
	#superclass : #FFICalloutAPI,
	#category : #'ThreadedFFI-UFFI'
}

{ #category : #'instance creation' }
TFCalloutAPI class >> newCallbackBackendFor: aCallback [

	^ TFCallback
		forBlock: aCallback
		parameters: (aCallback functionSpec arguments collect: #tfExternalTypeWithArity) asArray
		returnType: aCallback functionSpec returnType tfExternalTypeWithArity
]

{ #category : #action }
TFCalloutAPI >> newBuilder [

	^ TFCalloutMethodBuilder calloutAPI: self
]
