Extension { #name : #ExternalAddress }

{ #category : #'*ThreadedFFI' }
ExternalAddress >> address [
	"Answer the receiver's integer address"

	^self asInteger

]

{ #category : #'*ThreadedFFI' }
ExternalAddress >> thunk [ 

	^self
]
