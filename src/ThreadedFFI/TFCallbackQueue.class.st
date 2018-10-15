Class {
	#name : #TFCallbackQueue,
	#superclass : #Object,
	#instVars : [
		'semaphore',
		'semaphoreIndex'
	],
	#classVars : [
		'UniqueInstance'
	],
	#category : #ThreadedFFI
}

{ #category : #handlers }
TFCallbackQueue class >> new [
	
	self error: 'You should not create instances directly'.
]

{ #category : #handlers }
TFCallbackQueue class >> startUp: resuming [
	resuming
		ifFalse: [ ^ self ].

	UniqueInstance := self basicNew
		initialize;
		yourself
]

{ #category : #handlers }
TFCallbackQueue class >> uniqueInstance [

	^ UniqueInstance
]

{ #category : #initialization }
TFCallbackQueue >> initialize [

	semaphore := Semaphore new.
	semaphoreIndex := Smalltalk registerExternalObject: semaphore.
	
	self primInitializeQueue: semaphoreIndex.
]

{ #category : #initialization }
TFCallbackQueue >> primInitializeQueue: index [

	<primitive: 'primitiveInitializeCallbacksQueue' module: 'PThreadedPlugin'>

	^ self primitiveFailed	
]
