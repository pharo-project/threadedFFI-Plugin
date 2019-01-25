Class {
	#name : #TFRunner,
	#superclass : #FFIExternalReference,
	#category : #'ThreadedFFI-Worker'
}

{ #category : #executing }
TFRunner >> ensureInitialized [

	^ self subclassResponsibility
]

{ #category : #executing }
TFRunner >> executeFunction: aTFExternalFunction withArguments: argumentHolder withReturnHolder: aReturnHolder usingSemaphore: anInteger [

	^ self subclassResponsibility
]

{ #category : #execution }
TFRunner >> invokeFunction: aTFExternalFunction [ 
	
	^ self invokeFunction: aTFExternalFunction withArguments: #()
]

{ #category : #executing }
TFRunner >> invokeFunction: aTFExternalFunction withArguments: aCollection [ 

	^ aTFExternalFunction newCall
		parameters: aCollection;
		executeOn: self
]
