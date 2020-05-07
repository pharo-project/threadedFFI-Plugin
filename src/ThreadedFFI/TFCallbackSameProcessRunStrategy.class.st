Class {
	#name : #TFCallbackSameProcessRunStrategy,
	#superclass : #Object,
	#instVars : [
		'callbackProcess'
	],
	#classVars : [
		'Instance'
	],
	#category : #'ThreadedFFI-Callbacks'
}

{ #category : #'instance creation' }
TFCallbackSameProcessRunStrategy class >> new [

	self error: 'Use uniqueInstance'
]

{ #category : #'instance creation' }
TFCallbackSameProcessRunStrategy class >> uniqueInstance [ 

	^ Instance ifNil: [ Instance := self basicNew initialize; yourself]
]

{ #category : #'as yet unclassified' }
TFCallbackSameProcessRunStrategy >> callbackProcess [

	(callbackProcess isNotNil and: [ callbackProcess isTerminated not ])
		ifTrue: [ ^ callbackProcess ].
		
	callbackProcess := [ self waitForever ] newProcess.
	callbackProcess priority: Processor highIOPriority - 1.
	^ callbackProcess.
]

{ #category : #'as yet unclassified' }
TFCallbackSameProcessRunStrategy >> doExecuteCallback: aCallbackInvocation on: aTFRunner [

	aTFRunner handleExceptionDuring: [ aCallbackInvocation execute ]
]

{ #category : #'callback execution' }
TFCallbackSameProcessRunStrategy >> executeCallback: aCallbackInvocation on: aTFRunner [

	| process newContext methodToUse |
	process := self callbackProcess.
	methodToUse := self class >> #doExecuteCallback:on:.
	
	process suspend.
	newContext := Context 
		sender: process suspendedContext 
		receiver: self 
		method: methodToUse
		arguments: {aCallbackInvocation. aTFRunner}.

	process suspendedContext: newContext.
	process resume
]

{ #category : #'as yet unclassified' }
TFCallbackSameProcessRunStrategy >> waitForever [

	[ true ] whileTrue: [ 10 seconds wait ]
]
