Class {
	#name : #TFCallTypeWorker,
	#superclass : #TFExternalFunctionCallType,
	#instVars : [
		'worker'
	],
	#category : #'ThreadedFFI-Base'
}

{ #category : #'as yet unclassified' }
TFCallTypeWorker class >> worker: aWorker [ 

	^ self new worker: aWorker
]

{ #category : #'instance creation' }
TFCallTypeWorker >> newCallFor: aFunction [

	^ (TFExternalWorkerCall forFunction: aFunction)
		workerHandle: aFunction worker handle;
		yourself
]
