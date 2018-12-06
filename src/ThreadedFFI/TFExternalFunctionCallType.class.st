"
I'm a base class provide access to diferent call types (sync, async, async in queue, etc.)
My children provide concrete execution implementations.
"
Class {
	#name : #TFExternalFunctionCallType,
	#superclass : #Object,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'ThreadedFFI-Base'
}

{ #category : #'instance creation' }
TFExternalFunctionCallType class >> async [ 
	
	^ TFCallTypeAsync uniqueInstance
]

{ #category : #'instance creation' }
TFExternalFunctionCallType class >> asyncQueue [
	
	^ TFCallTypeAsyncInQueue default
]

{ #category : #'instance creation' }
TFExternalFunctionCallType class >> asyncQueue: aName [
	
	^ TFCallTypeAsyncInQueue queueNamed: aName
]

{ #category : #'instance creation' }
TFExternalFunctionCallType class >> sync [
	
	^ TFCallTypeSync uniqueInstance
]

{ #category : #'instance creation' }
TFExternalFunctionCallType >> newCallFor: aFunction [

	^ self subclassResponsibility
]
