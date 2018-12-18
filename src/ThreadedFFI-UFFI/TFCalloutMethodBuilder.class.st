Class {
	#name : #TFCalloutMethodBuilder,
	#superclass : #FFICalloutMethodBuilder,
	#category : #'ThreadedFFI-UFFI'
}

{ #category : #private }
TFCalloutMethodBuilder >> createFFICalloutLiteralFromSpec: functionSpec [
	| function |
	
	function := TFExternalFunction
		name: functionSpec functionName
		moduleName: self moduleName
		parameterTypes: (functionSpec arguments collect: #tfExternalTypeWithArity)
		returnType: functionSpec returnType tfExternalTypeWithArity
		worker: self module asFFILibrary worker.
		
	"(requestor optionAt: #optSync) ifTrue: [ 
		^ TFExternalFunctionCallType sync ]."
	(requestor optionAt: #optMainQueue) ifTrue: [ 
		function queue: TFFunctionQueue main ].
	(requestor optionAt: #optQueue) == false ifFalse: [ 
		function queue: (TFFunctionQueue named: (requestor optionAt: #optQueue)) ].
		
	^ function
]
