Class {
	#name : #TFBasicTypeTest,
	#superclass : #TestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #tests }
TFBasicTypeTest >> testBasicTypesAreValid [

	TFBasicType types do: #validate.
	self assert: (TFBasicType types allSatisfy: #isValid)
]

{ #category : #tests }
TFBasicTypeTest >> testPointerSize [

	self assert: TFBasicType pointer byteSize equals: Smalltalk wordSize 
]

{ #category : #tests }
TFBasicTypeTest >> testUInt32Size [

	self assert: TFBasicType uint32 byteSize equals: 4
]
