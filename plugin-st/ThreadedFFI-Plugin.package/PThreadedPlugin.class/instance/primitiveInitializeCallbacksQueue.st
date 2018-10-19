as yet unclassified
primitiveInitializeCallbacksQueue
	<export: true>
	<var: #index type: #int>
	
	|index|
	
	index := interpreterProxy integerValueOf: (interpreterProxy stackValue: 0).
	
	self initCallbackQueue: index.
	
	interpreterProxy failed
		ifFalse: [interpreterProxy pop: 1]