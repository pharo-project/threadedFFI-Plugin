Extension { #name : #FFICallback }

{ #category : #'*ThreadedFFI-UFFI' }
FFICallback >> worker [

	^ self ffiLibraryName 
		ifNotNil: [ :aLibrary | aLibrary asFFILibrary worker ] 
		ifNil: [ self workerManager workerNamed: self workerName ]
]

{ #category : #'*ThreadedFFI-UFFI' }
FFICallback >> workerManager [

	^ TFWorkerManager uniqueInstance
]

{ #category : #'*ThreadedFFI-UFFI' }
FFICallback >> workerName [

	^ #default
]
