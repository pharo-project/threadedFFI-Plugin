Extension { #name : #FFILibrary }

{ #category : #'*ThreadedFFI-UFFI' }
FFILibrary >> runner [ 
	
	^ TFWorker default
]
