"
I define a syncronic call. 
I will create a TFExternalSyncCall object.
"
Class {
	#name : #TFCallTypeSync,
	#superclass : #TFExternalFunctionCallType,
	#category : #'ThreadedFFI-Base'
}

{ #category : #'instance creation' }
TFCallTypeSync class >> new [ 

	self error: 'I''m a singleton class, use #uniqueInstance'
]

{ #category : #accessing }
TFCallTypeSync class >> uniqueInstance [ 

	^ uniqueInstance ifNil: [ uniqueInstance := super new ]
]

{ #category : #'instance creation' }
TFCallTypeSync >> newCallFor: aFunction [

	^ TFExternalSyncCall forFunction: aFunction
]
