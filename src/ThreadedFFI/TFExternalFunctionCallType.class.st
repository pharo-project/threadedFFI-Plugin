Class {
	#name : #TFExternalFunctionCallType,
	#superclass : #Object,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #ThreadedFFI
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

{ #category : #accessing }
TFExternalFunctionCallType >> id [ 
	
	^ self subclassResponsibility
]

{ #category : #'instance creation' }
TFExternalFunctionCallType >> newCallFor: aFunction [

	^ self subclassResponsibility
]
