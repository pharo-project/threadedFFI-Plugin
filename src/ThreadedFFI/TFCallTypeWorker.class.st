Class {
	#name : #TFCallTypeWorker,
	#superclass : #TFExternalFunctionCallType,
	#instVars : [
		'worker'
	],
	#category : #'ThreadedFFI-Base'
}

{ #category : #'instance creation' }
TFCallTypeWorker >> newCallFor: aFunction [

	^ (TFExternalWorkerCall forFunction: aFunction)
		workerHandle: self worker handle;
		yourself
]

{ #category : #accessing }
TFCallTypeWorker >> worker [
	^ worker
]

{ #category : #accessing }
TFCallTypeWorker >> worker: anObject [
	worker := anObject
]
