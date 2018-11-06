Extension { #name : #FFISizeT }

{ #category : #'*ThreadedFFI-UFFI' }
FFISizeT >> tfexternalType [

	^ FFIArchitecture forCurrentArchitecture tfexternalSizeTType
]
