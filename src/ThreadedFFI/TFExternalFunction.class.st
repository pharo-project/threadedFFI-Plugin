Class {
	#name : #TFExternalFunction,
	#superclass : #Object,
	#instVars : [
		'handle',
		'definition',
		'functionName',
		'moduleName'
	],
	#category : #ThreadedFFI
}

{ #category : #'as yet unclassified' }
TFExternalFunction class >> fromAddress: anExternalAddress definition: aFunctionDefinition [

	^ self new
		address: anExternalAddress;
		definition: aFunctionDefinition;
		yourself
]

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
	^ handle
]

{ #category : #accessing }
TFExternalFunction >> address: anObject [
	handle := anObject
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

{ #category : #operations }
TFExternalFunction >> newAsyncCall [

	^ TFExternalAsyncCall forFunction: self
]

{ #category : #operations }
TFExternalFunction >> validate [
	definition validate.
	handle isNull
		ifTrue: [ handle := ExternalAddress loadSymbol: functionName module: moduleName ]
]
