as yet unclassified
primitiveDefineFunction
	| receiver handler parameters returnType count paramsArray |
	<export: true>
	<var: #returnType type: #'void*'>
	<var: #parameters declareC: #'void** parameters'>
	<var: #handler type: #'void*'>
	<var: #count type: #'sqInt'>

	returnType := self readAddress: (interpreterProxy stackValue: 0).
	count := interpreterProxy stSizeOf: (interpreterProxy stackValue: 1).
	paramsArray := interpreterProxy stackValue: 1.
	receiver := interpreterProxy stackValue: 2.

	"The parameters are freed by the primitiveFreeDefinition, if there is an error it is freed by #defineFunction:With:And:"
	parameters := self cCode: 'malloc(count*sizeof(void*))' inSmalltalk: [Array new: count].
	
	0 to:(count - 1) do: [:idx | parameters at: idx put: (self readAddress: (interpreterProxy stObject: paramsArray at: (idx+1)))].
	
	interpreterProxy failed
		ifTrue: [^ nil].
	handler := self defineFunction:parameters With: count And: returnType.
	interpreterProxy failed
		ifTrue: [^ nil].
	self set: receiver Handler: handler.
	interpreterProxy failed
		ifFalse: [interpreterProxy pop: 2]