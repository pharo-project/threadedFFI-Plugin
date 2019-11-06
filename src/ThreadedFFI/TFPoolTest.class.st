Class {
	#name : #TFPoolTest,
	#superclass : #TestCase,
	#category : #'ThreadedFFI-Base'
}

{ #category : #tests }
TFPoolTest >> testReturnOne [
	| pool |
	
	pool := TFPool newProvider: [ 1 ] size: 2.
	
	pool takeOne; takeOne.
	self assert: pool isEmpty.
	self assert: pool size equals: 2.
	pool returnOne: 42.
	self deny: pool isEmpty.
	self assert: pool takeOne equals: 42.
	self assert: pool size equals: 2
]
