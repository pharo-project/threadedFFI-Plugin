Class {
	#name : #TFWorkerManagerTest,
	#superclass : #TestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #tests }
TFWorkerManagerTest >> runCaseManaged [

	super runCase
]

{ #category : #tests }
TFWorkerManagerTest >> testUnregisterWorker [
	| worker |

	worker := TFWorkerManager uniqueInstance registerWorkerName: #workerTest.
	self assert: (TFWorkerManager uniqueInstance 
		workerNamed: #workerTest 
		ifAbsent: [ nil ]) notNil.
	
	TFWorkerManager uniqueInstance unregisterWorker: worker.
	self assert: (TFWorkerManager uniqueInstance 
		workerNamed: #workerTest 
		ifAbsent: [ nil ]) isNil.
	
	"How to verify the thread is killed?"
]
