Class {
	#name : #BaselineOfThreadedFFI,
	#superclass : #BaselineOf,
	#category : #BaselineOfThreadedFFI
}

{ #category : #baseline }
BaselineOfThreadedFFI >> baseline: spec [
	<baseline>

	spec for: #common do: [

		spec
			package: 'ThreadedFFI';
			package: 'ThreadedFFI-UFFI' with: [ spec requires: #('ThreadedFFI')];
			package: 'ThreadedFFI-Tests' with: [ spec requires: #('ThreadedFFI')];
			package: 'ThreadedFFI-UFFI-Overrides' with: [ spec requires: #('ThreadedFFI-UFFI')];
			package: 'ThreadedFFI-UFFI-Tests' with: [ spec requires: #('ThreadedFFI-UFFI' 'ThreadedFFI-UFFI-Overrides')]
	].		

]
