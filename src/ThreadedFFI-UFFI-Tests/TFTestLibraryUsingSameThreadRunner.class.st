Class {
	#name : #TFTestLibraryUsingSameThreadRunner,
	#superclass : #FFILibrary,
	#category : #'ThreadedFFI-UFFI-Tests'
}

{ #category : #'accessing platform' }
TFTestLibraryUsingSameThreadRunner >> macModuleName [ 

	^ 'testLibrary.dylib'
]

{ #category : #accessing }
TFTestLibraryUsingSameThreadRunner >> runner [ 
	
	^ TFSameThreadRunner new
]

{ #category : #'accessing platform' }
TFTestLibraryUsingSameThreadRunner >> unixModuleName [

	^ 'testLibrary.so'
]

{ #category : #'accessing platform' }
TFTestLibraryUsingSameThreadRunner >> win32ModuleName [
 
	^ 'testLibrary.dll'
]
