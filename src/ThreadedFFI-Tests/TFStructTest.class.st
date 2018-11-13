Class {
	#name : #TFStructTest,
	#superclass : #TFTestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #tests }
TFStructTest >> pointSize [ 
	^ self ffiCall: #(int sizeOfPoint()) module: self libraryPath asFFILibrary 
]

{ #category : #tests }
TFStructTest >> testPointStructSize [

	| pointType |
	pointType := TFStructType forClass: TFPointTestStruct withMembers: { TFBasicType sint. TFBasicType sint. }.
	
	self assert: pointType byteSize equals: self pointSize.
	self assert: pointType byteSize equals: TFPointTestStruct byteSize.
	
]

{ #category : #tests }
TFStructTest >> testReturnsAnStruct [
	| pointType fun aPoint |
	pointType := TFStructType forClass: TFPointTestStruct withMembers: { TFBasicType sint. TFBasicType sint. }.
	
	fun := TFExternalFunction
		name: 'newPoint' moduleName: self libraryPath
		parameterTypes:	{TFBasicType sint. TFBasicType sint}
		returnType: pointType.
		
	aPoint := fun invokeWithArguments:#(1 5).

	self assert: aPoint x equals: 1.
	self assert: aPoint y equals: 5.	
]
