as yet unclassified
primitiveTypeByteSize
	| receiver handler size |
	<export: true>
	receiver := interpreterProxy stackValue: 0.
	handler := self getHandler: receiver.
	size := self getTypeByteSize: handler.
	interpreterProxy failed
		ifFalse: [interpreterProxy methodReturnInteger: size]