Class {
	#name : #TFTestResource,
	#superclass : #TestResource,
	#instVars : [
		'worker'
	],
	#category : #'ThreadedFFI-Tests'
}

{ #category : #running }
TFTestResource >> setUp [

	worker := TFWorkerManager uniqueInstance 
		workerNamed: #test
		ifAbsent: [ TFWorkerManager uniqueInstance registerWorkerName: #test ] 
]

{ #category : #running }
TFTestResource >> tearDown [

	"TFWorkerManager uniqueInstance unregisterWorker: worker"
]

{ #category : #accessing }
TFTestResource >> worker [ 

	^ worker
]
