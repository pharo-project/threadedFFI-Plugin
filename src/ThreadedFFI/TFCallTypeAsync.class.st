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
TFCallTypeAsync >> newCallFor: aFunction [

	^ TFExternalAsyncCall forFunction: aFunction
]
