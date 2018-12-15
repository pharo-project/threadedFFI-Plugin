Extension { #name : #FFICallback }

{ #category : #'*ThreadedFFI-UFFI' }
FFICallback >> worker [

	^ self ffiLibraryName asFFILibrary worker
]
