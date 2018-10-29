Extension { #name : #FFICallback }

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
FFICallback >> block: aBlock [
	block := aBlock
]

{ #category : #'*ThreadedFFI-UFFI-Overrides' }
FFICallback >> register [
	"declare the real callback"
	callback := Callback forCallbackEvaluator: self.
	"keeping the thunk here to easy the FFI method compilation"
	thunk := callback thunk.
]
