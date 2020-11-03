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
		moduleName: self libraryName
		parameterTypes: (functionSpec arguments collect: #tfExternalTypeWithArity)
		returnType: functionSpec returnType tfExternalTypeWithArity.
				
	^ function
]

{ #category : #private }
TFCalloutMethodBuilder >> generateFFICallout: builder spec: functionSpec [
	| properties ffiLibrary |

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
	ffiLibrary := library ifNil: [sender receiver ffiLibrary].	
	ffiLibrary := ffiLibrary isClass 
		ifFalse: [ ffiLibrary asFFILibrary ]
		ifTrue: [ ffiLibrary uniqueInstance ].
	
	builder 
		pushLiteral: (ffiLibrary uniqueInstance runner).
			
	"save ffi call as literal"
	builder pushLiteral: (self createFFICalloutLiteralFromSpec: functionSpec).
	"iterate arguments in order (in the function) to create the function call"
	
	functionSpec arguments 
		do: [ :each | 
			each emitArgument: builder context: sender inCallout: self requestor.
			each resolvedType tfExternalTypeWithArity emitMarshallToPrimitive: builder ].
	
	"create the array"
	builder pushConsArray: functionSpec arguments size.
	builder addTemp: #argumentsArray.
	builder storeTemp: #argumentsArray.
	
	"send call and store into result"
	builder send: #invokeFunction:withArguments:.

	functionSpec arguments withIndexDo: [ :each :index| 
		each emitReturnArgument: builder context: sender.
		each resolvedType tfExternalTypeWithArity 
			emitFreeIfNeededOfIndex: index
			argumentsArrayTempName: #argumentsArray
			withBuilder: builder  ].
	
	"Additional marshall in the case of TFFI"	
	functionSpec returnType resolvedType tfExternalTypeWithArity emitMarshallFromPrimitive: builder.

	"convert in case return type needs it. And return reseult"	
	
	^ functionSpec returnType
		emitReturn: builder
		resultTempVar: #result
		context: sender
		inCallout: self requestor
]
