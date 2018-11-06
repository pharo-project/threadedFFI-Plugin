Class {
	#name : #TFUFFITestCase,
	#superclass : #TestCase,
	#category : #'ThreadedFFI-UFFI-Tests'
}

{ #category : #testing }
TFUFFITestCase class >> isAbstract [

	^ self == TFUFFITestCase
]

{ #category : #accessing }
TFUFFITestCase >> calloutAPIClass [

	^ TFCalloutAPI
]
