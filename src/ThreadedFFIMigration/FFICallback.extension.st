Extension { #name : #FFICallback }

{ #category : #'*ThreadedFFIMigration' }
FFICallback >> arguments [ 

	^ functionSpec 
		ifNil: [ #() ] 
		ifNotNil: [ functionSpec arguments ]
]

{ #category : #'*ThreadedFFIMigration' }
FFICallback >> returnType [ 

	^ functionSpec
		ifNil: [ TFBasicType void ]
		ifNotNil: [ functionSpec returnType  ]
]
