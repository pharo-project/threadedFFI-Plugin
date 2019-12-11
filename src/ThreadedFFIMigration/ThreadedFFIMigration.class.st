"
ThreadedFFIMigration provides a number of methods to allow code to be written that can be used in both Squeak only FFI and Threaded FFI environments.

It is expected that once the migration to Threaded FFI is complete, automatic re-write rules using the deprecation framework will be introduced to remove all references to ThreadedFFIMigration, which will then be removed.


Public API and Key Messages

- threadedFFIAvailable   answer a boolean indicating whether the threaded FFI functionality is currently available.

 
Internal Representation and Key Implementation Points.


    Implementation Points
"
Class {
	#name : #ThreadedFFIMigration,
	#superclass : #Object,
	#classVars : [
		'DisableThreadedFFI',
		'ThreadedFFIAvailable'
	],
	#category : #ThreadedFFIMigration
}

{ #category : #managing }
ThreadedFFIMigration class >> disableThreadedFFI [
	"Set the flag forcing Threaded FFI to be disabled"
	<script>

	DisableThreadedFFI := true.
]

{ #category : #managing }
ThreadedFFIMigration class >> enableThreadedFFI [
	"Clear the flag forcing Threaded FFI to be disabled"
	<script>

	DisableThreadedFFI := false.
]

{ #category : #private }
ThreadedFFIMigration class >> getThreadedFFIAvailable [
	"Determine whether threaded ffi is available and set the flag"

	| result ba |

	result := [ 
		ba := #[1 2 3].
		ba pinInMemory.
		PointerUtils oopForObject: ba.
		ba unpinInMemory.
		true ]
			on: Error 
			do: [ false ].
	^result
]

{ #category : #'class initialization' }
ThreadedFFIMigration class >> initialize [ 

	SessionManager default
		registerSystemClassNamed: self name
		atPriority: 20
]

{ #category : #initialization }
ThreadedFFIMigration class >> reset [ 

	ThreadedFFIAvailable := nil.
]

{ #category : #'system startup' }
ThreadedFFIMigration class >> shutDown: quitting [
	"Force to detect Threaded FFI Availability if the VM may change"

	self reset
]

{ #category : #'system startup' }
ThreadedFFIMigration class >> startUp: resuming [
	"Force to detect Threaded FFI Availability if the VM may have changed"

	self reset
]

{ #category : #accesing }
ThreadedFFIMigration class >> threadedFFIAvailable [
	"Answer a boolean indicating whether to use Threaded FFI"

	"If true, DisableThreadedFFI forces Threaded FFI to be NOT used.
	Allow for nil value (= false)"
	DisableThreadedFFI == true ifTrue: [ ^false ].
	^ThreadedFFIAvailable ifNil: [ ThreadedFFIAvailable := self getThreadedFFIAvailable ]
]
