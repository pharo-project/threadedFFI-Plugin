Extension { #name : #Object }

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
Object >> calloutAPIClass [
	^ FFICalloutAPI calloutAPIClass
]

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
Object >> newCallbackWithSignature: signature block: aBlock [
	self flag: #TODO. "Do we really need this method?"
	
	^ (self ffiCalloutIn: thisContext sender)
		convention: self ffiCallingConvention;
		newCallbackWithSignature: signature
			block: aBlock
			library: self ffiLibraryName
]

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
Object >> newCallbackWithSignature: signature block: aBlock library: aFFILibrary [
	self flag: #TODO. "Do we really need this method?"
	
	^ (self ffiCalloutIn: thisContext sender)
		convention: self ffiCallingConvention;
		newCallbackWithSignature: signature
			block: aBlock
			library: aFFILibrary
]
