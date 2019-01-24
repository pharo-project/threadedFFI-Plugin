Class {
	#name : #TFCalloutAPI,
	#superclass : #FFICalloutAPI,
	#category : #'ThreadedFFI-UFFI'
}

{ #category : #'instance creation' }
TFCalloutAPI class >> newCallbackBackendFor: aCallback [

	^ TFCallback
		forCallback: aCallback
		parameters: (aCallback functionSpec arguments collect: #tfExternalTypeWithArity) asArray
		returnType: aCallback functionSpec returnType tfExternalTypeWithArity
		runner: aCallback worker
]

{ #category : #action }
TFCalloutAPI >> newBuilder [

	^ TFCalloutMethodBuilder calloutAPI: self
]
