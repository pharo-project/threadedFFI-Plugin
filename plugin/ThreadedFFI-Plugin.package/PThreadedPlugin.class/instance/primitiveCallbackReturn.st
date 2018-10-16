as yet unclassified
primitiveCallbackReturn
	| receiver handler |
	<export: true>
	<var: #handler type: #'void* '>
	<var: #callbackDataPtr type: #'CallbackData* '>

	receiver := interpreterProxy stackValue: 0.
	handler := self getHandler: receiver.
	
	self callbackReturn: handler.