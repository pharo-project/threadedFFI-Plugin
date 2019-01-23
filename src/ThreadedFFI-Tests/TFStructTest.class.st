Class {
	#name : #TFStructTest,
	#superclass : #TFTestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #tests }
TFStructTest >> longStructSize [ 
	^ self ffiCall: #(int sizeOfLongStruct()) module: self libraryPath asFFILibrary 
]

{ #category : #tests }
TFStructTest >> pointSize [ 
	^ self ffiCall: #(int sizeOfPoint()) module: self libraryPath asFFILibrary 
]

{ #category : #tests }
TFStructTest >> testLongStructSize [
	| pointType |
	pointType := TFStructType
		forClass: TFLongTestStruct
		withMembers:
			(Array new: 100 withAll: TFBasicType schar)
				,	{TFBasicType float.
					TFBasicType double.
					TFBasicType slong.
					TFBasicType sint.
					TFBasicType sshort}.
	self assert: pointType byteSize equals: self longStructSize.
	self assert: TFLongTestStruct byteSize equals: self longStructSize
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
	
	pointType := TFStructType 
		forClass: TFPointTestStruct 
		withMembers: { 
			TFBasicType sint. 
			TFBasicType sint }.
	
	fun := TFExternalFunction
		name: 'newPoint' moduleName: self libraryPath
		parameterTypes:	{TFBasicType sint. TFBasicType sint}
		returnType: pointType.
		
	aPoint := runner invokeFunction: fun withArguments: #(1 5).

	self assert: aPoint x equals: 1.
	self assert: aPoint y equals: 5.	
]
