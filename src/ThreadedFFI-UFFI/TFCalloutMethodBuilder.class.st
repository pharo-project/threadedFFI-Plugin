Class {
	#name : #TFCalloutMethodBuilder,
	#superclass : #FFICalloutMethodBuilder,
	#category : #'ThreadedFFI-UFFI'
}

{ #category : #private }
TFCalloutMethodBuilder >> callType [
	
	"(requestor optionAt: #optSync) ifTrue: [ 
		^ TFExternalFunctionCallType sync ].
	(requestor optionAt: #optMainQueue) ifTrue: [ 
		^ TFExternalFunctionCallType asyncQueue ].
	(requestor optionAt: #optQueue) == false ifFalse: [ 
		^ (TFExternalFunctionCallType asyncQueue: (requestor optionAt: #optQueue)) ].
	
	^ TFExternalFunctionCallType async"
	
	^ TFCallTypeWorker new 
		worker: self module asFFILibrary worker;
		yourself
]

{ #category : #private }
TFCalloutMethodBuilder >> createFFICalloutLiteralFromSpec: functionSpec [
	| function |

	function := TFExternalFunction
		name: functionSpec functionName
		moduleName: self moduleName
		parameterTypes: (functionSpec arguments collect: #tfExternalTypeWithArity)
		returnType: functionSpec returnType tfExternalTypeWithArity.	

	function callType: self callType.
	
	^ function
]
