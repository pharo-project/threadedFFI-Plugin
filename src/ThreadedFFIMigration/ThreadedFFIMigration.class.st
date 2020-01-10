"
ThreadedFFIMigration provides a number of methods to allow code to be written that can be used in both Squeak only FFI and Threaded FFI environments.

It is expected that once the migration to Threaded FFI is complete, automatic re-write rules using the deprecation framework will be introduced to remove all references to ThreadedFFIMigration, which will then be removed.

Threaded FFI can be enabled and disabled by sending  the messages #enableThreadedFFI and #disableThreadedFFI.

""""Requirements""""

To enable Threaded FFI:

1. A headless VM with the appropriate plugin must be used.

[[[
	ThreadedFFIMigration getThreadedFFIAvailable
]]]

will answer a boolean indicating if the current VM supports Threaded FFI.

Note that as of January 2020 this is a custom Gtoolkit version of the plugin that fixes thread synchronisation issues in the Pharo version of the plugin.  See *https://github.com/pharo-project/threadedFFI-Plugin/pull/17* for more information.


2. The ThreadedFFIMigration enabled flag must be true.

This can be enabled or disabled with: 

[[[ 
	ThreadedFFI enableThreadedFFI.
]]]

and 

[[[ 
	ThreadedFFI disableThreadedFFI.
]]]

The overall status of threaded TFFI can be checked with: 

[[[ 
	ThreadedFFI threadedFFIAvailable.
]]]


""""WARNING:""""

Alien callbacks and Threaded FFI callbacks may not be used together within the same session (due to different stack management strategies).

To switch between enabled and disabled modes changing the flag must be the last thing done before saving the image and quitting.

A safe way to do this from the Unix command line is: 

[[[language=bash
gtoolkit Pharo.image eval --save --quit ""ThreadedFFIMigration enableThreadedFFI."" 
]]]

and 

[[[language=bash
gtoolkit Pharo.image eval --save --quit ""ThreadedFFIMigration disableThreadedFFI."" 
]]]

If Pharo is being configured as part of a script, the enable / disable commands must be the last step before saving the image and quitting.


!!Public API and Key Messages

- ==threadedFFIAvailable==   answer a boolean indicating whether the threaded FFI functionality is currently available.
- ==disableThreadedFFI==		disable the use of Threaded FFI even if the VM supports it.
- ==enableThreadedFFI== 		enable the use of Threaded FFI if the VM supports it.

 
!!!Internal Representation and Key Implementation Points.


!!Implementation Points

"
Class {
	#name : #ThreadedFFIMigration,
	#superclass : #Object,
	#classVars : [
		'ThreadedFFIAvailable',
		'ThreadedFFIEnabled'
	],
	#category : #ThreadedFFIMigration
}

{ #category : #managing }
ThreadedFFIMigration class >> disableThreadedFFI [
	"Set the flag forcing Threaded FFI to be disabled"
	<script>

	ThreadedFFIEnabled := false.
]

{ #category : #managing }
ThreadedFFIMigration class >> enableThreadedFFI [
	"Clear the flag forcing Threaded FFI to be disabled"
	<script>

	ThreadedFFIEnabled := true.
]

{ #category : #private }
ThreadedFFIMigration class >> getThreadedFFIAvailable [
	"Determine whether threaded ffi is available and set the flag"

	| result |

	"Use a Gt specific version for now to ensure we have the Gt version 
	of libPThreadedPlugin.so"
	"result := [ 
		ba := #[1 2 3].
		ba pinInMemory.
		PointerUtils oopForObject: ba.
		ba unpinInMemory.
		true ]
			on: Error 
			do: [ false ]."
	result := self primitiveGtTFFIversion.
	^result > 16r10000
]

{ #category : #'class initialization' }
ThreadedFFIMigration class >> initialize [ 

	self disableThreadedFFI.
	SessionManager default
		registerSystemClassNamed: self name
		atPriority: 20
]

{ #category : #accessing }
ThreadedFFIMigration class >> primitiveGtTFFIversion [

	<primitive: 'primitiveGtTFFIversion' module: 'PThreadedPlugin' error: ec>
	ec = #'not found' ifTrue: [ ^0 ].
	self primitiveFailed: ec
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

	^ThreadedFFIEnabled and: [ ThreadedFFIAvailable 
		ifNil: [ ThreadedFFIAvailable := self getThreadedFFIAvailable ] ]
]
