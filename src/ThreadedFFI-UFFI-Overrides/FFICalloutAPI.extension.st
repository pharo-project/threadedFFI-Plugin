Extension { #name : #FFICalloutAPI }

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
FFICalloutAPI class >> newCallbackBackendFor: aCallback [

	^ FFIAlienCallback fromFrontendCallback: aCallback
]

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
FFICalloutAPI >> newCallbackWithSignature: signature block: aBlock library: aLibrary [

	^ (FFICallback signature: signature block: aBlock)
		calloutAPIClass: self class;
		ffiLibrary: aLibrary;
		yourself
]
