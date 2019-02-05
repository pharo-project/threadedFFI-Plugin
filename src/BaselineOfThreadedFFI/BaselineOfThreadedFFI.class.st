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
				baseline: 'ParametrizedTests' 
				with: [ 
					spec
						repository: 'github://tesonep/ParametrizedTests/src';
	  					loads: 'default' ].
		spec 
			package: 'UnifiedFFI';
			package: 'UnifiedFFI-Tests' with: [ spec requires: #('UnifiedFFI')];
			package: 'ThreadedFFI' with: [ spec requires: #('UnifiedFFI')];
			package: 'ThreadedFFI-UFFI' with: [ spec requires: #('ThreadedFFI')];
			package: 'ThreadedFFI-Tests' with: [ spec requires: #('ThreadedFFI' 'ParametrizedTests')];
			package: 'ThreadedFFI-UFFI-Overrides' with: [ spec requires: #('ThreadedFFI-UFFI')];
			package: 'ThreadedFFI-UFFI-Tests' with: [ spec requires: #('ThreadedFFI-UFFI' 'ThreadedFFI-UFFI-Overrides' 'UnifiedFFI-Tests')]
	].		

]
