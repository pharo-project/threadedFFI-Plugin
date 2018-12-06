"
I define an asyncronic call. 
I will create a TFExternalAsyncCall object.
"
Class {
	#name : #TFCallTypeAsync,
	#superclass : #TFExternalFunctionCallType,
	#category : #'ThreadedFFI-Base'
}

{ #category : #'instance creation' }
TFCallTypeAsync class >> new [ 

	self error: 'I''m a singleton class, use #uniqueInstance'
]

{ #category : #'instance creation' }
TFCallTypeAsync class >> uniqueInstance [ 

	^ uniqueInstance ifNil: [ uniqueInstance := super new ]
]

{ #category : #'instance creation' }
TFCallTypeAsync >> newCallFor: aFunction [

	^ TFExternalAsyncCall forFunction: aFunction
]
