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
		returnType: functionSpec returnType tfExternalTypeWithArity.
				
	^ function
]

{ #category : #private }
TFCalloutMethodBuilder >> generateFFICallout: builder spec: functionSpec [
	| properties |

	"Copy the properties of the old method"
	sender methodProperties ifNotNil: [ 
		properties := sender methodProperties copy.
		properties method: nil.
		builder properties: properties ].
	
	builder
		numArgs: self method argumentNames size;
		addTemps: (self method argumentNames copyWith: #result).

	TFCalloutAPI isTracing ifTrue: [ 
		TFCalloutAPI trace: sender. 
		builder 
			pushLiteral: TFCalloutAPI;
			pushLiteral: sender;
			send: #trace: ].

	"Obtain the library to use"
	builder 
		pushReceiver;
		send: #ffiLibrary;
		send: #uniqueInstance.
		
	"Obtain the runner to use."
	builder send: #runner.
	
	"save ffi call as literal"
	builder pushLiteral: (self createFFICalloutLiteralFromSpec: functionSpec).
	"iterate arguments in order (in the function) to create the function call"
	functionSpec arguments do: [ :each | each emitArgument: builder context: sender ].
	"create the array"
	builder pushConsArray: functionSpec arguments size.
	"send call and store into result"
	builder send: #invokeFunction:withArguments:.
	
	functionSpec arguments do: [ :each | each emitReturnArgument: builder context: sender ].
	"convert in case return type needs it. And return reseult"
	^ functionSpec returnType emitReturn: builder resultTempVar: #result context: sender
]
