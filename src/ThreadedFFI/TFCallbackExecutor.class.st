"
I am an object in charge of guaranteeing the correct LIFO execution of callbacks.
In other words, I guarantee that a the last callback that entered should return before previous callbacks.

Such execution order is required to keep the C stack safe. For example, imagine a C stack as follows (stack grows up)

frame 7 - interpreter() ""executing other callback""
frame 6 - othercallback()
frame 5 - othercallout()
frame 4 - interpreter() ""executing first callback""
frame 3 - somecallback()
frame 2 - somecallout()
frame 1 - intepreter()

If when at frame 7, the first callback returns to frame 3, it will potentially corrupt the stack of the frames 4-7.
Moreover, when the interpreter regains control and the second callback returns, it will return to frame 6, which is no longer valid.

In a threaded FFI implementation, one instance of myself needs to exist per-native-thread to ensure the stack is preserved per-thread.

Implementation details
======================

My single entry point is the #schedule: message receiving a callback invocation (understanding #execute).
Internally, I execute all callbacks in a single process with user priority (40).
When a new callback is scheduled, I preempt that callback execution by stacking a new context on that process which will execute the new callback.
When a callback context returns, the execution jumps back to the previously preempted context callback.
To ensure the manipulation of the callback process is safe, scheduling should happen from a higher priority process.

This chaining makes sure that only one callback is active at point in the execution moment, and that a callback only gets execution time if it is the last callback that entered.

Take into account that I provide a singleton instance for the current VM thread, that is restarted at each startup because the stack is also restarted.
"
Class {
	#name : #TFCallbackExecutor,
	#superclass : #Object,
	#instVars : [
		'process'
	],
	#category : #'ThreadedFFI-Callbacks'
}

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
