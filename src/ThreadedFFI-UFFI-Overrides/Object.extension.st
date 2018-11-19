Extension { #name : #Object }

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
Object >> calloutAPIClass [
	^ FFICalloutAPI calloutAPIClass
]

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
Object >> newCallbackWithSignature: signature block: aBlock [
	^ (self ffiCalloutIn: thisContext sender)
		convention: self ffiCallingConvention;
		newCallbackWithSignature: signature
		block: aBlock
]
