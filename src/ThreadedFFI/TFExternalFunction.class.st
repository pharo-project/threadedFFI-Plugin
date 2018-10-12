Class {
	#name : #TFExternalFunction,
	#superclass : #Object,
	#instVars : [
		'address',
		'definition',
		'functionName',
		'moduleName'
	],
	#category : #ThreadedFFI
}

{ #category : #'as yet unclassified' }
TFExternalFunction class >> name: aName moduleName: aModuleName definition: aFunctionDefinition [

	^ self new
		address: ExternalAddress new;
		moduleName: aModuleName;
		functionName: aName;
		definition: aFunctionDefinition;
		yourself
]

{ #category : #accessing }
TFExternalFunction >> address [
	^ address
]

{ #category : #accessing }
TFExternalFunction >> address: anObject [
	address := anObject
]

{ #category : #accessing }
TFExternalFunction >> definition [
	^ definition
]

{ #category : #accessing }
TFExternalFunction >> definition: anObject [
	definition := anObject
]

{ #category : #accessing }
TFExternalFunction >> functionName [
	^ functionName
]

{ #category : #accessing }
TFExternalFunction >> functionName: anObject [
	functionName := anObject
]

{ #category : #accessing }
TFExternalFunction >> moduleName [
	^ moduleName
]

{ #category : #accessing }
TFExternalFunction >> moduleName: anObject [
	moduleName := anObject
]

{ #category : #accessing }
TFExternalFunction >> validate [
	definition validate.
	address isNull
		ifTrue: [ address := ExternalAddress loadSymbol: functionName module: moduleName ]
]
