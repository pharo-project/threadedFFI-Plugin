Class {
	#name : #TFCalloutMethodBuilder,
	#superclass : #FFICalloutMethodBuilder,
	#category : #'ThreadedFFI-UFFI'
}

{ #category : #private }
TFCalloutMethodBuilder >> createFFICalloutLiteralFromSpec: functionSpec [

	^ TFExternalFunction
		name: functionSpec functionName
		moduleName: self moduleName
		parameterTypes: (functionSpec arguments collect: #tfexternalTypeWithArity)
		returnType: functionSpec returnType tfexternalTypeWithArity
]
