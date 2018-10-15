as yet unclassified
primitiveReadNextCallback
	<export: true>
	| externalAddress address |
	<var: #address type: #'CallbackData*'>
	
	externalAddress := interpreterProxy stackValue: 0.
	address := self getNextCallback.
	self write: externalAddress Address: address.
	
	interpreterProxy failed
		ifFalse: [interpreterProxy pop: 1]