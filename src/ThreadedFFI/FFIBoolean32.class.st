Class {
	#name : #FFIBoolean32,
	#superclass : #FFIExternalType,
	#category : #'ThreadedFFI-Types'
}

{ #category : #accessing }
FFIBoolean32 class >> externalType [
	^ ExternalType bool
]

{ #category : #accessing }
FFIBoolean32 class >> externalTypeAlignment [
	^ 1
]

{ #category : #accessing }
FFIBoolean32 class >> externalTypeSize [
	^ 1
]

{ #category : #private }
FFIBoolean32 >> basicHandle: aHandle at: index [

	^ (aHandle signedLongAt: index) ~~ 0
]

{ #category : #private }
FFIBoolean32 >> basicHandle: aHandle at: index put: value [

	^ aHandle signedLongAt: index put: value asBit
]

{ #category : #accessing }
FFIBoolean32 >> defaultReturnOnError [

	^ false
]

{ #category : #'stack parameter classification' }
FFIBoolean32 >> stackValueParameterClass [
	^ #integer
]

{ #category : #accessing }
FFIBoolean32 >> tfExternalType [
	
	^ TFDerivedType boolean32
]
