Class {
	#name : #TFCallbackExecutor,
	#superclass : #Object,
	#instVars : [
		'process',
		'semaphore',
		'runner',
		'protet'
	],
	#classVars : [
		'ThisProcess'
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
	ThisProcess ifNil: [ 
		ThisProcess := [ 
			[aCallbackInvocation execute] on: Error do: [ :e | 
				Stdio stdout nextPutAll: 'Error! ', e signalerContext stack asString, ' from ', aCallbackInvocation callback frontendCallback asString; crlf.].
			ThisProcess := nil. ] newProcess.
		ThisProcess priority: 40.
		^ ThisProcess resume
	].
	
	previous := ThisProcess suspendedContext.
	callbackContext := [ 
		[aCallbackInvocation execute] on: Error do: [ :e | 
			Stdio stdout nextPutAll: 'Error! ', e signalerContext stack asString, ' from ', aCallbackInvocation callback frontendCallback asString; crlf.].
		previous jump.
	] asContext.
	callbackContext privSender: previous.
	ThisProcess suspendedContext: callbackContext.
]
