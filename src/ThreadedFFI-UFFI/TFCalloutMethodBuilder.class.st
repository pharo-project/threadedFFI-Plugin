Class {
	#name : #TFCalloutMethodBuilder,
	#superclass : #FFICalloutMethodBuilder,
	#category : #'ThreadedFFI-UFFI'
}

{ #category : #private }
TFCalloutMethodBuilder >> callType [
	
	(requestor optionAt: #optSync) ifTrue: [ 
		^ TFExternalFunctionCallType sync ].
	(requestor optionAt: #optMainQueue) ifTrue: [ 
		^ TFExternalFunctionCallType asyncQueue ].
	(requestor optionAt: #optQueue) == false ifFalse: [ 
		^ (TFExternalFunctionCallType asyncQueue: (requestor optionAt: #optQueue)) ].
	
	^ TFExternalFunctionCallType async
]

{ #category : #private }
TFCalloutMethodBuilder >> createFFICalloutLiteralFromSpec: functionSpec [
	| function |

	function := TFExternalFunction
		name: functionSpec functionName
		moduleName: self moduleName
		parameterTypes: (functionSpec arguments collect: #tfexternalTypeWithArity)
		returnType: functionSpec returnType tfexternalTypeWithArity.	

	function callType: self callType.
	
	^ function
]
