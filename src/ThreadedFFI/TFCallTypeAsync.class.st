Class {
	#name : #TFCallTypeAsync,
	#superclass : #TFExternalFunctionCallType,
	#category : #ThreadedFFI
}

{ #category : #'instance creation' }
TFCallTypeAsync class >> new [ 

	self error: 'I''m a singleton class, use #uniqueInstance'
]

{ #category : #'instance creation' }
TFCallTypeAsync class >> uniqueInstance [ 

	^ uniqueInstance ifNil: [ uniqueInstance := super new ]
]

{ #category : #accessing }
TFCallTypeAsync >> id [ 

	^ 1
]

{ #category : #'instance creation' }
TFCallTypeAsync >> newCallFor: aFunction [

	^ TFExternalAsyncCall forFunction: aFunction
]
