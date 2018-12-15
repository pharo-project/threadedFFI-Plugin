Extension { #name : #FFILibrary }

{ #category : #'*ThreadedFFI' }
FFILibrary >> options [

	^ #()
]

{ #category : #'*ThreadedFFI' }
FFILibrary >> worker [

	^ self workerManager ensureWorkerNamed: self workerName
		
]

{ #category : #'*ThreadedFFI' }
FFILibrary >> workerManager [

	^ TFWorkerManager uniqueInstance
]

{ #category : #'*ThreadedFFI' }
FFILibrary >> workerName [

	^ #default
]
