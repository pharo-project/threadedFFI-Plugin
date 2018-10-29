Extension { #name : #FFIExternalType }

{ #category : #'*ThreadedFFI-UFFI' }
FFIExternalType >> tfexternalType [
		
	^ self subclassResponsibility
]

{ #category : #'*ThreadedFFI-UFFI' }
FFIExternalType >> tfexternalTypeWithArity [
	
	^ self pointerArity > 0 
		ifTrue: [ TFBasicType pointer ]
		ifFalse: [ self tfexternalType ]
]
