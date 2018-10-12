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
TFFunctionDefinition class >> fromHandle: aHandle [
	
	^ self error: 'should not be used'
]

{ #category : #'instance creation' }
TFFunctionDefinition class >> parameterTypes: someParameters returnType: returnType [

	^ self new
		parameterTypes: someParameters;
		returnType: returnType;
		autoRelease;
		yourself
]

{ #category : #accessing }
TFFunctionDefinition >> parameterTypes [
	^ parameterTypes
]

{ #category : #accessing }
TFFunctionDefinition >> parameterTypes: anObject [
	parameterTypes := anObject
]

{ #category : #primitives }
TFFunctionDefinition >> primDefineFunctionWith: parameterHandlers returnType: returnTypeHandler [ 
	
	<primitive: 'primitiveDefineFunction' module: 'PThreadedPlugin' error: ec>

	^ self primitiveFailed	
]

{ #category : #accessing }
TFFunctionDefinition >> returnType [
	^ returnType
]

{ #category : #accessing }
TFFunctionDefinition >> returnType: anObject [
	returnType := anObject
]

{ #category : #accessing }
TFFunctionDefinition >> validate [
	| parameterHandlers |

	handle isNull ifFalse: [ ^self ].

	"First, we get valid parameter handles."
	parameterTypes do: [ :e | e validate ].
	returnType validate.
	
	parameterHandlers := parameterTypes collect: [ :e | e getHandle ] as: Array.
	self primDefineFunctionWith: parameterHandlers returnType: returnType getHandle
]
