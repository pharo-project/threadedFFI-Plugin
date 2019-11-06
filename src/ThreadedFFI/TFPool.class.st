"
I am a generic pool to be used whith TFFI. 
My main usage will be to keep a pool of external semaphores, avoiding the creation/registration/unregistration of an external semaphore each external call.
"
Class {
	#name : #TFPool,
	#superclass : #Object,
	#instVars : [
		'mutex',
		'elements',
		'provider',
		'initialSize',
		'pointer'
	],
	#category : #'ThreadedFFI-Base'
}

{ #category : #'instance creation' }
TFPool class >> newProvider: aBlock size: aNumber [

	^ self basicNew 
	initializeProvider: aBlock size: aNumber;
	yourself
]

{ #category : #private }
TFPool >> growBy: aNumber [

	elements := elements, (Array new: aNumber).
	self populate: aNumber
]

{ #category : #accessing }
TFPool >> growRate [
 
	^ initialSize // 2
]

{ #category : #initialization }
TFPool >> initialize [

	super initialize.
	mutex := Mutex new
]

{ #category : #initialization }
TFPool >> initializeProvider: aBlock size: aNumber [

	self initialize.
	provider := aBlock.
	elements := Array new: aNumber.
	initialSize := aNumber.
	pointer := 1.
	self populate: initialSize
]

{ #category : #testing }
TFPool >> isEmpty [
	
	^ elements allSatisfy: #isNil
]

{ #category : #testing }
TFPool >> isOverflown [

	^ pointer > elements size
]

{ #category : #private }
TFPool >> populate: aNumber [

	pointer to: (pointer + aNumber - 1) do: [ :index |
		elements at: index put: provider value ]
]

{ #category : #accessing }
TFPool >> returnOne: anObject [

	mutex critical: [ 
		| index |
		index := pointer - 1. 
		index > 0 ifFalse: [ 
			^ self error: 'Returning an object but pool is full' ]. 
		elements at: index put: anObject.
		pointer := index ]
]

{ #category : #accessing }
TFPool >> size [

	^ elements size
]

{ #category : #accessing }
TFPool >> takeOne [
	| element |

	^ mutex critical: [ 
		self isOverflown
			ifTrue: [ self growBy: self growRate ].
		element := elements at: pointer.
		elements at: pointer put: nil.
		pointer := pointer + 1.
		element ]
]
