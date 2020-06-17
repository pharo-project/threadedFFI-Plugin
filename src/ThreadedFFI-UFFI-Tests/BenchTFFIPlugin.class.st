Class {
	#name : #BenchTFFIPlugin,
	#superclass : #Object,
	#category : #'ThreadedFFI-UFFI-Tests-Benchs'
}

{ #category : #accessing }
BenchTFFIPlugin >> calloutAPIClass [ 

	^ TFCalloutAPI
]

{ #category : #'as yet unclassified' }
BenchTFFIPlugin >> doCallWith: aFloat another: aDouble [

	^ self ffiCall: #(float sumAFloatAndADouble(float aFloat, double aDouble))
]

{ #category : #accessing }
BenchTFFIPlugin >> ffiLibrary [

	^ TFTestLibraryUsingSameThreadRunner uniqueInstance
]

{ #category : #'as yet unclassified' }
BenchTFFIPlugin >> runCall [

	| return | 

	^ [ return := self doCallWith: 1.0 another: 2.0.
		 self assert: return = 3.0 ] bench
]
