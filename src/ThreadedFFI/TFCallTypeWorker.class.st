Class {
	#name : #TFCallTypeWorker,
	#superclass : #TFExternalFunctionCallType,
	#category : #'ThreadedFFI-Base'
}

{ #category : #'as yet unclassified' }
TFCallTypeWorker class >> worker: aWorker [ 

	^ self new worker: aWorker
]

{ #category : #'instance creation' }
TFCallTypeWorker >> newCallFor: aFunction [

	^ TFExternalWorkerCall forFunction: aFunction
]
