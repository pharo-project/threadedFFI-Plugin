Class {
	#name : #FFIAlienCallback,
	#superclass : #Object,
	#instVars : [
		'frontendCallback',
		'thunk',
		'callback'
	],
	#category : #'UnifiedFFI-Callbacks'
}

{ #category : #'instance creation' }
FFIAlienCallback class >> fromFrontendCallback: aFFICallback [

	^ self new
		frontendCallback: aFFICallback;
		yourself
]

{ #category : #'as yet unclassified' }
FFIAlienCallback >> argumentsFor: stackPointer context: callbackContext [
	| index architecture intRegisterCount intRegisterSize intRegisterIndex floatRegisterCount floatRegisterSize floatRegisterIndex floatRegisters intRegisters structureRegisterLayout |
	self flag: 'TODO: Refactor and improve this code.'.
	architecture := FFIArchitecture forCurrentArchitecture.
	
	intRegisterCount := architecture integerRegisterCountForParameterPassing.
	intRegisterSize := architecture integerRegisterSize.
	intRegisterIndex := 0.
	
	floatRegisterCount := architecture floatRegisterCountForParameterPassing.
	floatRegisterSize := architecture floatRegisterSize.
	floatRegisterIndex := 0.
	
	floatRegisters := callbackContext floatregargsp.
	intRegisters := callbackContext intregargsp.
	
	index := 1 + architecture shadowCallSpaceSize.
	^ frontendCallback functionSpec arguments 
		collect: [ :each | | value parameterClass |
			parameterClass := each stackParameterClass.
			(parameterClass == #integer and: [ intRegisterIndex < intRegisterCount and: [each typeSize <= intRegisterSize ]]) ifTrue: [
				value := each callbackValueFor: intRegisters at: intRegisterIndex*intRegisterSize + 1.
				intRegisterIndex := intRegisterIndex + 1
			] ifFalse: [ 
				(parameterClass == #float and: [ floatRegisterIndex < floatRegisterCount and: [each typeSize <= floatRegisterSize ]]) ifTrue: [
					value := each callbackValueFor: floatRegisters at: floatRegisterIndex*floatRegisterSize + 1.
					floatRegisterIndex := floatRegisterIndex + 1
				] ifFalse: [
					(parameterClass == #structure and:
					[ (structureRegisterLayout := architecture computeStructureRegisterPassingLayout: each objectClass) isNotNil and:
					[intRegisterIndex + structureRegisterLayout integerRegisterCount <= intRegisterSize and:
					[floatRegisterIndex + structureRegisterLayout floatRegisterCount <= floatRegisterSize]]]) ifTrue: [
						"This is structure whose content was splitted in registers."
						value := each objectClass new.
						structureRegisterLayout fields do: [ :structureField |
							structureField registerClass == #integer ifTrue: [
								1 to: structureField size do: [ :i |
									value getHandle byteAt: structureField offset + i put:
										(intRegisters unsignedByteAt: intRegisterIndex*intRegisterSize + i)
								].
							] ifFalse: [
								self assert: structureField registerClass == #float.
								1 to: structureField size do: [ :i |
									value getHandle byteAt: structureField offset + i put:
										(floatRegisters unsignedByteAt: floatRegisterIndex*floatRegisterSize + i)
								].
								floatRegisterIndex := floatRegisterIndex + 1
							] 
						]
					] ifFalse: [ 
						"Memory parameter" 
						value := each callbackValueFor: stackPointer at: index.
						index := index + each typeSize.
					]
				].
			].
		
			value ].	
]

{ #category : #accessing }
FFIAlienCallback >> frontendCallback [
	^ frontendCallback
]

{ #category : #accessing }
FFIAlienCallback >> frontendCallback: anObject [
	frontendCallback := anObject.
	
	self register
]

{ #category : #registering }
FFIAlienCallback >> register [
	"declare the real callback"
	callback := Callback forCallbackEvaluator: self.
	"keeping the thunk here to easy the FFI method compilation"
	thunk := callback thunk.
]

{ #category : #accessing }
FFIAlienCallback >> thunk [
	^ thunk
]

{ #category : #evaluation }
FFIAlienCallback >> valueWithContext: callbackContext sp: stackPointer [ 
	| argumentValues |
	
	self flag: #todo. "This can be optimised in a shadow method"
	argumentValues := self argumentsFor: stackPointer context: callbackContext.
	^ frontendCallback functionSpec returnType 
		callbackReturnOn: callbackContext 
		for: (frontendCallback valueWithArguments: argumentValues)
]
