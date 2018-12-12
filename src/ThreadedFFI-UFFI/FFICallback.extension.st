Extension { #name : #FFICallback }

{ #category : #'*ThreadedFFI-UFFI' }
FFICallback >> ffiLibraryName [

	self flag: #TODO. "This should be a variable, but no time for refactor now :)"
	^ nil
]

{ #category : #'*ThreadedFFI-UFFI' }
FFICallback >> worker [

	^ self ffiLibraryName 
		ifNotNil: [ :library | library asFFILibrary worker ] 
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
