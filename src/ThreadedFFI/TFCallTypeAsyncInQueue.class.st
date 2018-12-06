"
I define an asyncronic call using a system queue. 
I will create a TFExternalAsyncCallInQueue object.
"
Class {
	#name : #TFCallTypeAsyncInQueue,
	#superclass : #TFCallTypeAsync,
	#instVars : [
		'queueName'
	],
	#category : #'ThreadedFFI-Base'
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
