Extension { #name : #LGitLibrary }

{ #category : #'*ThreadedFFIMigration' }
LGitLibrary >> calloutAPIClass [
	^ ThreadedFFIMigration threadedFFIAvailable
		ifTrue: [ TFCalloutAPI ]
		ifFalse: [ super calloutAPIClass ]
]

{ #category : #'*ThreadedFFIMigration' }
LGitLibrary >> runner [ 

	^ ThreadedFFIMigration threadedFFIAvailable
		ifTrue: [ TFSameThreadRunner uniqueInstance ]
		ifFalse: [ super runner ]

]

{ #category : #'*ThreadedFFIMigration' }
LGitLibrary >> safeCalloutAPIClass [
	^ ThreadedFFIMigration threadedFFIAvailable
		ifTrue: [ TFLGitSafeFFICalloutAPI ]
		ifFalse: [ LGitSafeFFICalloutAPI ]
]
