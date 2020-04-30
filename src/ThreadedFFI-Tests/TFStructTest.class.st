Class {
	#name : #TFStructTest,
	#superclass : #TFTestCase,
	#category : #'ThreadedFFI-Tests'
}

{ #category : #tests }
TFStructTest >> longStructSize [ 

	^ TFWorker default
		invokeFunction:
			(TFExternalFunction
				name: 'sizeOfLongStruct'
				moduleName: self libraryPath
				definition:
					(TFFunctionDefinition parameterTypes: {} returnType: TFBasicType uint))
		withArguments: #()

]

{ #category : #tests }
TFStructTest >> pointSize [

	^ TFWorker default
		invokeFunction:
			(TFExternalFunction
				name: 'sizeOfPoint'
				moduleName: self libraryPath
				definition:
					(TFFunctionDefinition parameterTypes: {} returnType: TFBasicType uint))
		withArguments: #()
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
TFStructTest >> testReadStruct [

	| pointType fun aPoint pointHandle readedPoint |
	
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
	
	pointHandle := aPoint getHandle.
	readedPoint := (pointType readValue: pointHandle copy).
	
	self deny: aPoint equals:readedPoint .
	self assert: aPoint x equals: readedPoint x.
	self assert: aPoint y equals: readedPoint y.
	
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

{ #category : #tests }
TFStructTest >> testWriteStruct [
	| pointType fun aPoint pointHandle otherPoint |
	pointType := TFStructType
		forClass: TFPointTestStruct
		withMembers:
			{TFBasicType sint.
			TFBasicType sint}.
	fun := TFExternalFunction
		name: 'newPoint'
		moduleName: self libraryPath
		parameterTypes:
			{TFBasicType sint.
			TFBasicType sint}
		returnType: pointType.
	aPoint := runner invokeFunction: fun withArguments: #(1 5).
	
	
	pointHandle := aPoint getHandle.
	otherPoint := aPoint deepCopy. 
	otherPoint x: 3.
	otherPoint y: 1.

	self deny: aPoint x equals: otherPoint x.
	self deny: aPoint y equals: otherPoint y.
	pointType write: otherPoint into: pointHandle.
	self assert: aPoint x equals: otherPoint x.
	self assert: aPoint y equals: otherPoint y
]
