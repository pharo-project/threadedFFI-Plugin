Class {
	#name : #BaselineOfThreadedFFI,
	#superclass : #BaselineOf,
	#category : #BaselineOfThreadedFFI
}

{ #category : #baseline }
BaselineOfThreadedFFI >> baseline: spec [
	<baseline>

	spec for: #common do: [

		spec postLoadDoIt: #reset.

		spec
			"ThreadedFFI and ThreadedFFIMigration are interdependent,
			but ThreadedFFI uses ThreadedFFIMigration during the load"
			package: 'ThreadedFFIMigration';
			package: 'ThreadedFFI' with: [ spec requires: #('ThreadedFFIMigration') ];
			package: 'ThreadedFFI-UFFI' with: [ spec requires: #('ThreadedFFI') ];
			package: 'ThreadedFFI-Tests' with: [ spec requires: #('ThreadedFFI') ];
			package: 'ThreadedFFI-UFFI-Overrides' with: [ spec requires: #('ThreadedFFI-UFFI') ];
			package: 'ThreadedFFI-UFFI-Tests' with: [ spec requires: #('ThreadedFFI-UFFI' 'ThreadedFFI-UFFI-Overrides') ] ].		

]

{ #category : #doits }
BaselineOfThreadedFFI >> reset [

	Smalltalk globals
		at: #FFIMethodRegistry 
		ifPresent: [ :class | class resetAll ]
]
