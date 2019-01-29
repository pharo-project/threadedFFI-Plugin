Class {
	#name : #TFTestLibraryUsingWorker,
	#superclass : #FFILibrary,
	#category : #'ThreadedFFI-UFFI-Tests'
}

{ #category : #'accessing platform' }
TFTestLibraryUsingWorker >> macModuleName [ 

	^ 'testLibrary.dylib'
]

{ #category : #accessing }
TFTestLibraryUsingWorker >> runner [ 
	
	^ TFWorker default
]

{ #category : #'accessing platform' }
TFTestLibraryUsingWorker >> unixModuleName [

	^ 'testLibrary.so'
]

{ #category : #'accessing platform' }
TFTestLibraryUsingWorker >> win32ModuleName [
 
	^ 'testLibrary.dll'
]
