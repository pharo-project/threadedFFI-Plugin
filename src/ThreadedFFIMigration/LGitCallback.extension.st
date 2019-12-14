Extension { #name : #LGitCallback }

{ #category : #'*ThreadedFFIMigration' }
LGitCallback >> calloutAPIClass [
	^ ThreadedFFIMigration threadedFFIAvailable
		ifTrue: [ TFCalloutAPI ]
		ifFalse: [ super calloutAPIClass ]
]

{ #category : #'*ThreadedFFIMigration' }
LGitCallback >> ffiLibraryName [
	^ self class ffiLibraryName
]

{ #category : #'*ThreadedFFIMigration' }
LGitCallback class >> ffiLibraryName [
	^ LGitLibrary
]
