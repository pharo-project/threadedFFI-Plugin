as yet unclassified
primitiveFreeDefinition
	| handler receiver |
	<export: true>
	<var: #handler type: #'void*'>

	receiver := interpreterProxy stackValue: 0.
	handler := self getHandler: receiver.

	handler = 0 ifTrue: [ ^ self].

	self cCode: 'free(((ffi_cif*)handler)->arg_types)'.
	self cCode: 'free(handler)'.

	self set: receiver Handler: 0.
