Extension { #name : #FFICalloutAPI }

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
FFICalloutAPI >> newCallbackWithSignature: signature block: aBlock [

	| functionSpec |
	functionSpec := self newParser parseAnonymousFunction: signature.
	^ FFICallback new
		functionSpec: functionSpec;
		block: aBlock;
		register;
		yourself
]
