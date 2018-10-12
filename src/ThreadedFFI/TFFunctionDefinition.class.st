Class {
	#name : #TFFunctionDefinition,
	#superclass : #FFIExternalReference,
	#instVars : [
		'parameterTypes',
		'returnType'
	],
	#category : #ThreadedFFI
}

{ #category : #'instance creation' }
TFFunctionDefinition class >> finalizeResourceData: handle [
	handle isNull ifTrue: [ ^ self ].

	self primReleaseFunction: handle
]

{ #category : #'instance creation' }
TFFunctionDefinition class >> fromHandle: aHandle [
	
	^ self error: 'should not be used'
]
