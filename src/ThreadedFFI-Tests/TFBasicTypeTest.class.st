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
