Class {
	#name : #TFCallTypeSync,
	#superclass : #TFExternalFunctionCallType,
	#category : #ThreadedFFI
}

{ #category : #'instance creation' }
TFCallTypeSync class >> new [ 

	self error: 'I''m a singleton class, use #uniqueInstance'
]

{ #category : #accessing }
TFCallTypeSync class >> uniqueInstance [ 

	^ uniqueInstance ifNil: [ uniqueInstance := super new ]
]

{ #category : #accessing }
TFCallTypeSync >> id [ 

	^ 2
]

{ #category : #'instance creation' }
TFCallTypeSync >> newCallFor: aFunction [

	^ TFExternalSyncCall forFunction: aFunction
]
