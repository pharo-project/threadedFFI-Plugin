"
I represent an external function from a library.
I have a name, a TFFunctionDefinition type signature and I am fetched from an external library.

TFExternalFunction
	name: 'functionName'
	moduleName: 'pathToLibrary'
	definition: (TFFunctionDefinition
		parameterTypes: { TFBasicType pointer }
		returnType: TFBasicType sint).

To execute myself you can call my #execute and #executeWithArguments: method.
These will create an async function call and block the current pharo process while waiting for its finish.

!! Examples

((TFExternalFunction
	name: 'getenv'
	moduleName: LibC uniqueInstance moduleName
	parameterTypes: { TFBasicType pointer }
	returnType: TFBasicType pointer)
		executeWithArguments: { ExternalAddress fromString: 'HOME' utf8Encoded }) readString asByteArray utf8Decoded.
"
Class {
	#name : #TFExternalFunction,
	#superclass : #Object,
	#instVars : [
		'handle',
		'definition',
		'functionName',
		'moduleName',
		'callTypeId',
		'callType'
	],
	#category : #'ThreadedFFI-Base'
}

{ #category : #private }
TFExternalFunction class >> defaultCallType [

	^ TFExternalFunctionCallType async
]

{ #category : #'instance creation' }
TFExternalFunction class >> fromAddress: anExternalAddress definition: aFunctionDefinition [

	^ self new
		address: anExternalAddress;
		definition: aFunctionDefinition;
		yourself
]

{ #category : #'instance creation' }
TFExternalFunction class >> name: aName moduleName: aModuleName definition: aFunctionDefinition [

	^ self new
		address: ExternalAddress new;
		moduleName: aModuleName;
		functionName: aName;
		definition: aFunctionDefinition;
		yourself
]

{ #category : #'instance creation' }
TFExternalFunction class >> name: aName moduleName: aModuleName parameterTypes: parameterTypes returnType: returnType [


	^ self
		name: aName
		moduleName: aModuleName
		definition: (TFFunctionDefinition 
			parameterTypes: parameterTypes
			returnType: returnType)

]

{ #category : #'instance creation' }
TFExternalFunction class >> name: aName moduleName: aModuleName parameterTypes: parameterTypes returnType: returnType type: aFunctionCallType [


	^ (self
		name: aName
		moduleName: aModuleName
		definition: (TFFunctionDefinition 
			parameterTypes: parameterTypes
			returnType: returnType))
		type: aFunctionCallType;
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
TFExternalFunction >> callType [
	^ callType
]

{ #category : #accessing }
TFExternalFunction >> callType: aCallType [

	callType := aCallType.
	callTypeId := callType id.
]

{ #category : #accessing }
TFExternalFunction >> callTypeId [
	"This is utilitary for the plugin side. 
	 Is easier and faster to check for a code than inspects an object"

	^ callTypeId
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

{ #category : #operations }
TFExternalFunction >> invoke [

	^ self invokeWithArguments: #()
]

{ #category : #operations }
TFExternalFunction >> invokeWithArguments: arguments [

	^ self newCall
		parameters: arguments;
		execute
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
TFExternalFunction >> newCall [

	^ self callType newCallFor: self
]

{ #category : #operations }
TFExternalFunction >> validate [
	definition validate.
	handle isNull
		ifTrue: [ handle := ExternalAddress loadSymbol: functionName module: moduleName ]
]
