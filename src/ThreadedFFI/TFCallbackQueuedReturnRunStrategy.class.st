Class {
	#name : #TFCallbackQueuedReturnRunStrategy,
	#superclass : #TFCallbackForkRunStrategy,
	#instVars : [
		'queue',
		'mutex'
	],
	#classVars : [
		'Instance'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'ThreadedFFI-Callbacks'
}

{ #category : #'instance creation' }
TFCallbackQueuedReturnRunStrategy class >> new [

	self error: 'Use #uniqueInstance'
]

{ #category : #'instance creation' }
TFCallbackQueuedReturnRunStrategy class >> uniqueInstance [ 

	^ uniqueInstance ifNil: [ uniqueInstance := super new ]
]

{ #category : #executing }
TFCallbackQueuedReturnRunStrategy >> executeCallback: aCallbackInvocation on: aRunner [

	self push: aCallbackInvocation.
	[ 
		aRunner handleExceptionDuring: [ 
			aCallbackInvocation executeThen: [ 
				self return: aCallbackInvocation ] ].
	]
	forkAt: Processor highIOPriority - 1
]

{ #category : #initialization }
TFCallbackQueuedReturnRunStrategy >> initialize [

	super initialize.
	mutex := Mutex new.
	queue := OrderedCollection new: 10
]

{ #category : #adding }
TFCallbackQueuedReturnRunStrategy >> isEmpty [

	^ queue isEmpty
]

{ #category : #adding }
TFCallbackQueuedReturnRunStrategy >> peek [

	^ mutex critical: [ queue last ]
]

{ #category : #adding }
TFCallbackQueuedReturnRunStrategy >> pop [

	^ mutex critical: [ queue removeLast ]
]

{ #category : #adding }
TFCallbackQueuedReturnRunStrategy >> push: aCallbackInvocation [

	"Stdio stdout 
		<< 'PUSH ' 
		<< aCallbackInvocation callback getHandle printString
		<< ' (' << queue size asString << ')'; 
		lf; flush."
	mutex critical: [ 
		queue add: aCallbackInvocation ]
]

{ #category : #executing }
TFCallbackQueuedReturnRunStrategy >> return: aCallbackInvocation [
	| next |
	
	self peek == aCallbackInvocation ifFalse: [ ^ self ].
	self pop.
	"Stdio stdout 
		<< 'RETURN ' 
		<< aCallbackInvocation callback getHandle printString << ' '
		<< aCallbackInvocation callback frontendCallback tfPrintString << ' '
		<< aCallbackInvocation returnExecution printString; lf; flush."
	self isEmpty ifTrue: [ ^ self ].
	((next := self peek) isReadyToReturn) 
		ifTrue: [ 
			"Stdio stdout << 'RETURN NEXT'; lf; flush. "
			self return: next ]
]
