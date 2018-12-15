Class {
	#name : #TFTestLibrary,
	#superclass : #FFILibrary,
	#category : #'ThreadedFFI-UFFI-Tests'
}

{ #category : #'accessing platform' }
TFTestLibrary >> macModuleName [ 

	^ 'testLibrary.dylib'
]

{ #category : #'accessing platform' }
TFTestLibrary >> unixModuleName [

	^ 'testLibrary.so'
]

{ #category : #'accessing platform' }
TFTestLibrary >> win32ModuleName [
 
	^ 'testLibrary.dll'
]

{ #category : #accessing }
TFTestLibrary >> workerName [ 

	^ #test
]
