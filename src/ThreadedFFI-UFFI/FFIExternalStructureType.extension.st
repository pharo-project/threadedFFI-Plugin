Extension { #name : #FFIExternalStructureType }

{ #category : #'*ThreadedFFI-UFFI' }
FFIExternalStructureType >> tfexternalType [
	^ TFStructType forClass: objectClass withMembers: (objectClass fieldSpec fields values collect: [ :aField | aField tfexternalType ] )
]
