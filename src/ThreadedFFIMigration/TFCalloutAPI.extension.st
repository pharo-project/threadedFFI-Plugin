Extension { #name : #TFCalloutAPI }

{ #category : #'*ThreadedFFIMigration' }
TFCalloutAPI class >> newCallbackBackendFor: aCallback [

	^ TFCallback
		forCallback: aCallback
		parameters: (aCallback arguments collect: #tfExternalTypeWithArity) asArray
		returnType: aCallback returnType tfExternalTypeWithArity
		runner: aCallback ffiLibrary uniqueInstance runner
]
