Extension { #name : #FFICalloutMethodBuilder }

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
FFICalloutMethodBuilder >> newParser [
	^ FFIFunctionParser new  
		requestor: self requestor;
		yourself
]

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
FFICalloutMethodBuilder >> parseSignature: aSignature [
	^ self newParser parseNamedFunction: aSignature
]
