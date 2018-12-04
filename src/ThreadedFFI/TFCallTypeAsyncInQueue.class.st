Class {
	#name : #TFCallTypeAsyncInQueue,
	#superclass : #TFExternalFunctionCallType,
	#instVars : [
		'queueName'
	],
	#classInstVars : [
		'types'
	],
	#category : #ThreadedFFI
}

{ #category : #'instance creation' }
TFCallTypeAsyncInQueue class >> default [ 

	^ self types 
		at: #default 
		ifAbsentPut: [ super new ]
]

{ #category : #'instance creation' }
TFCallTypeAsyncInQueue class >> new [ 

	self error: 'Use #default or #queueNamed: instead.'
]

{ #category : #'instance creation' }
TFCallTypeAsyncInQueue class >> queueNamed: aName [

	^ self types 
		at: aName
		ifAbsentPut: [ super new queueNamed: aName ]
]

{ #category : #private }
TFCallTypeAsyncInQueue class >> types [ 

	^ types ifNil: [ types := Dictionary new ]
]

{ #category : #accessing }
TFCallTypeAsyncInQueue >> id [ 

	^ 3
]

{ #category : #'instance creation' }
TFCallTypeAsyncInQueue >> newCallFor: aFunction [

	^ (TFExternalAsyncCallInQueue forFunction: aFunction)
		queueName: self queueName;
		yourself
]

{ #category : #accessing }
TFCallTypeAsyncInQueue >> queueName [
	^ queueName
]

{ #category : #accessing }
TFCallTypeAsyncInQueue >> queueName: anObject [
	queueName := anObject
]
