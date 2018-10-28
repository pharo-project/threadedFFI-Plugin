Extension { #name : #Object }

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
Object >> calloutAPIClass [
	^ FFICalloutAPI calloutAPIClass
]

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
Object >> ffiCallout [
	^ self calloutAPIClass inContext: thisContext sender
]

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
Object >> ffiCalloutIn: aContext [
	^ self calloutAPIClass inContext: aContext
]
