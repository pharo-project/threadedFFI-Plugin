Class {
	#name : #TFUFFIStructuresTest,
	#superclass : #TFUFFITestCase,
	#category : #'ThreadedFFI-UFFI-Tests'
}

{ #category : #'as yet unclassified' }
TFUFFIStructuresTest >> passStructByParameter: aPoint x: x y: y [

	^ self ffiCall: #(int assertCorrectPoint(TFPointTestStruct aPoint, int x, int y))
]

{ #category : #'as yet unclassified' }
TFUFFIStructuresTest >> passStructByReference: aPoint [

	^ self ffiCall: #(void* id_pointer(TFPointTestStruct* aPoint))
]

{ #category : #'as yet unclassified' }
TFUFFIStructuresTest >> returnNewPointX: x Y: y [

	^ self ffiCall: #(TFPointTestStruct newPoint(int x, int y))
]

{ #category : #'as yet unclassified' }
TFUFFIStructuresTest >> testPassingByParameterAStructInC [

	| aPoint return |
	aPoint := TFPointTestStruct externalNew
					autoRelease;
					yourself.
	
	aPoint x: 21.
	aPoint y: 33.
	
	return := self passStructByParameter: aPoint x: 21 y: 33.
	self assert: return equals: 1.

]

{ #category : #'as yet unclassified' }
TFUFFIStructuresTest >> testPassingByParameterAStructInPharo [

	| aPoint return |
	aPoint := TFPointTestStruct new.
	
	aPoint x: 21.
	aPoint y: 33.
	
	return := self passStructByParameter: aPoint x: 21 y: 33.
	self assert: return equals: 1.

]

{ #category : #'as yet unclassified' }
TFUFFIStructuresTest >> testPassingByReferenceAStructInC [

	| aPoint return |
	aPoint := TFPointTestStruct externalNew
					autoRelease;
					yourself.
	
	aPoint x: 21.
	aPoint y: 33.
	
	return := self passStructByReference: aPoint.
	self assert: return asInteger equals: aPoint getHandle asInteger.

]

{ #category : #'as yet unclassified' }
TFUFFIStructuresTest >> testReturningAnStruct [

	| aPoint |
	aPoint := self returnNewPointX: 1 Y: 2.

	self assert: aPoint x equals: 1.
	self assert: aPoint y equals: 2.	
]
