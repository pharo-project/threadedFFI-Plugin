as yet unclassified
primitivePerformCall
	|  aExternalFunction parametersAddress returnHolderAddress  semaphoreIndex  aCif |
	<export: true>
	<var: #aExternalFunction type: #'void*'>
	<var: #aCif type: #'void*'>
	<var: #parametersAddress type: #'void*'>
	<var: #returnHolderAddress type: #'void*'>
	<var: #semaphoreIndex type: #'sqInt'>

	semaphoreIndex := interpreterProxy integerValueOf: (interpreterProxy stackValue: 0).
	returnHolderAddress := self readAddress: (interpreterProxy stackValue: 1).
	parametersAddress := self readAddress: (interpreterProxy stackValue: 2).
	aExternalFunction := self getHandler: (interpreterProxy stackValue: 3).
	aCif := self getHandler: (interpreterProxy fetchPointer: 1 ofObject: (interpreterProxy stackValue: 3)).
	
	interpreterProxy failed
		ifTrue: [^ nil].

	self performCall: aExternalFunction Cif: aCif With: parametersAddress Into: returnHolderAddress Using: semaphoreIndex.
	
	interpreterProxy failed
		ifTrue: [^ nil].

	interpreterProxy failed
		ifFalse: [interpreterProxy pop: 4]