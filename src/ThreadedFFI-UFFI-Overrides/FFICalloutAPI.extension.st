Extension { #name : #FFICalloutAPI }

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
FFICalloutAPI class >> newCallbackBackendFor: aCallback [

	^ FFIAlienCallback fromFrontendCallback: aCallback
]
