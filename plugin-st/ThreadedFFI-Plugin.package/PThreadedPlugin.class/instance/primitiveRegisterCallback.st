as yet unclassified
primitiveRegisterCallback
	| receiver callbackData parameters paramArray count handler callbackDataPtr returnType|
	<export: true>
	<var: #parameters type: #'ffi_type** '>
	<var: #returnType type: #'ffi_type* '>
	<var: #count type: #'sqInt'>
	<var: #handler type: #'void* '>
	<var: #callbackDataPtr type: #'CallbackData* '>

	receiver := interpreterProxy stackValue: 0.
	callbackData := interpreterProxy fetchPointer: 1 ofObject: receiver.
	paramArray := interpreterProxy fetchPointer: 2 ofObject: receiver.
	count := interpreterProxy stSizeOf: paramArray.
	callbackDataPtr := self cCode: 'NULL' inSmalltalk: [nil].
	
	"The parameters are freed by the primitiveFreeDefinition, if there is an error it is freed by #defineCallback:WithParams:Count:ReturnType:"
	parameters := self cCode: 'malloc(count*sizeof(void*))' inSmalltalk: [Array new: count].
	returnType := self getHandler: (interpreterProxy fetchPointer: 3 ofObject: receiver).
	
	0 to:(count - 1) do: [:idx | parameters at: idx put: (self getHandler: (interpreterProxy stObject: paramArray at: (idx+1)))].
	
	interpreterProxy failed
		ifTrue: [^ nil].
		
	handler := self defineCallback: (self addressOf: callbackDataPtr) 
					WithParams: parameters 
					Count: count
					ReturnType: returnType.
	
	interpreterProxy failed
		ifTrue: [^ nil].
	
	self set: receiver Handler: handler.
	self write: callbackData Address: callbackDataPtr.