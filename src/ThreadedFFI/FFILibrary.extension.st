Extension { #name : #FFILibrary }

{ #category : #'*ThreadedFFI' }
FFILibrary >> options [

	^ #()
]

{ #category : #'*ThreadedFFI' }
FFILibrary >> worker [

	^ self workerManager workerNamed: self workerName
]

{ #category : #'*ThreadedFFI' }
FFILibrary >> workerManager [

	^ TFWorkerManager uniqueInstance
]

{ #category : #'*ThreadedFFI' }
FFILibrary >> workerName [

	^ #default
]
