Extension { #name : #FFICharacterType }

{ #category : #'*ThreadedFFI-UFFI' }
FFICharacterType >> tfexternalType [
	
	^ TFBasicType schar
]

{ #category : #'*ThreadedFFI-UFFI' }
FFICharacterType >> tfexternalTypeWithArity [
	
	"If it is a char* we can assume it is a String"
	self pointerArity = 1 ifTrue: [ ^TFDerivedType string ]. 

	^ super tfexternalTypeWithArity
]
