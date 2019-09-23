Extension { #name : #FFILibrary }

{ #category : #'*ThreadedFFI-UFFI' }
FFILibrary >> runner [ 
	
	^ TFSameThreadRunner uniqueInstance
]
