Class {
	#name : #TFCalloutAPI,
	#superclass : #FFICalloutAPI,
	#category : #'ThreadedFFI-UFFI'
}

{ #category : #action }
TFCalloutAPI >> newBuilder [

	^ TFCalloutMethodBuilder calloutAPI: self
]

{ #category : #action }
TFCalloutAPI >> newCallbackWithSignature: signature block: aBlock [

	| functionSpec |
	functionSpec := (FFIFunctionParser new
		requestor: (FFICallout new
			requestor: FFICallback new;
			yourself);
		yourself) parseAnonymousFunction: signature.
	^ TFCallback
		forBlock: aBlock
		parameters: (functionSpec arguments collect: #tfexternalTypeWithArity) asArray
		returnType: functionSpec returnType tfexternalTypeWithArity
]
