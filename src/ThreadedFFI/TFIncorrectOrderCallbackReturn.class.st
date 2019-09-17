"
I am an error indicating a callback tries to return in an incorrect order.
I notify the user with the problematic callback and the list of callbacks that should have returned before.
"
Class {
	#name : #TFIncorrectOrderCallbackReturn,
	#superclass : #Error,
	#instVars : [
		'previousCallbacks',
		'callbackInvocation'
	],
	#category : #'ThreadedFFI-Callbacks'
}

{ #category : #accessing }
TFIncorrectOrderCallbackReturn >> callback [
	^ self callbackInvocation callback
]

{ #category : #accessing }
TFIncorrectOrderCallbackReturn >> callbackInvocation [
	^ callbackInvocation
]

{ #category : #accessing }
TFIncorrectOrderCallbackReturn >> callbackInvocation: anObject [
	callbackInvocation := anObject
]

{ #category : #accessing }
TFIncorrectOrderCallbackReturn >> previousCallbacks [
	^ previousCallbacks
]

{ #category : #accessing }
TFIncorrectOrderCallbackReturn >> previousCallbacks: anObject [
	previousCallbacks := anObject
]
