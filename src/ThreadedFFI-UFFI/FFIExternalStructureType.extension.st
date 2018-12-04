Extension { #name : #FFIExternalStructureType }

{ #category : #'*ThreadedFFI-UFFI' }
FFIExternalStructureType >> tfExternalType [
	^ TFStructType
		forClass: objectClass
		withMembers:
			(objectClass fieldSpec fields values
				flatCollect: [ :aField | aField tfExternalTypeForStructureWithArity ])
]
