Class {
	#name : #TFCallbackExecutor,
	#superclass : #Object,
	#instVars : [
		'process',
		'semaphore',
		'runner',
		'protet'
	],
	#category : #'ThreadedFFI-Callbacks'
}

{ #category : #initialization }
TFCallbackExecutor >> runner: aRunner [

	runner := aRunner
]

{ #category : #'user-api' }
TFCallbackExecutor >> schedule: aCallbackInvocation [

	| previous callbackContext |
	process ifNil: [ 
		process := [ 
			[aCallbackInvocation execute] on: Error do: [ :e | 
				Stdio stdout nextPutAll: 'Error! ', e signalerContext stack asString, ' from ', aCallbackInvocation callback frontendCallback asString; crlf.].
			process := nil. ] newProcess.
		process priority: 40.
		^ process resume
	].
	
	previous := process suspendedContext.
	callbackContext := [ 
		[aCallbackInvocation execute] on: Error do: [ :e | 
			Stdio stdout nextPutAll: 'Error! ', e signalerContext stack asString, ' from ', aCallbackInvocation callback frontendCallback asString; crlf.].
		previous jump.
	] asContext.
	callbackContext privSender: previous.
	process suspendedContext: callbackContext.
]
