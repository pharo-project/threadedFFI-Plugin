as yet unclassified
primitiveUnregisterCallback

	| receiver callbackDataPtr callbackData |
	<export: true>
	<var: #callbackDataPtr type: #'CallbackData* '>

	receiver := interpreterProxy stackValue: 0.
	callbackData := interpreterProxy fetchPointer: 1 ofObject: receiver.
	callbackDataPtr := self readAddress: callbackData.
	
	self releaseCallback: callbackDataPtr.