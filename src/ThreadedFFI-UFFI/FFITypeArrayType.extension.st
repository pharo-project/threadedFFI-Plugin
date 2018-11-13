Extension { #name : #FFITypeArrayType }

{ #category : #'*ThreadedFFI-UFFI' }
FFITypeArrayType >> tfexternalTypeForStructure [

	^ Array new: self objectClass numberOfElements withAll: self tfexternalType
]
