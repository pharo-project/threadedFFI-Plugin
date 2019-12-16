Class {
	#name : #TFCalloutAPI,
	#superclass : #FFICalloutAPI,
	#classVars : [
		'TraceBlock'
	],
	#category : #'ThreadedFFI-UFFI'
}

{ #category : #tracing }
TFCalloutAPI class >> activateTrace [

	self activateTraceWith: [ :sender | sender crTrace ]
]

{ #category : #tracing }
TFCalloutAPI class >> activateTraceWith: aBlock [

	TraceBlock := aBlock.
	FFIMethodRegistry resetAll
]

{ #category : #tracing }
TFCalloutAPI class >> isTracing [

	^ TraceBlock notNil
]

{ #category : #'as yet unclassified' }
TFCalloutAPI class >> newCallbackBackendFor: aCallback [

	^ TFCallback
		forCallback: aCallback
		parameters: (aCallback arguments collect: #tfExternalTypeWithArity) asArray
		returnType: aCallback returnType tfExternalTypeWithArity
		runner: aCallback ffiLibrary uniqueInstance runner
]

{ #category : #tracing }
TFCalloutAPI class >> resetTrace [
	<script>
	
	TraceBlock := nil.
	FFIMethodRegistry resetAll
]

{ #category : #tracing }
TFCalloutAPI class >> trace: sender [
	"This method is not to be used directly, it is called by TFFI when #activateTrace was called."

	TraceBlock ifNil: [ ^ self ].
	TraceBlock value: sender
]

{ #category : #action }
TFCalloutAPI >> newBuilder [

	^ TFCalloutMethodBuilder calloutAPI: self
]
