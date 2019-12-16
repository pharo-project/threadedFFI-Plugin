Class {
	#name : #BaselineOfThreadedFFIMigration,
	#superclass : #BaselineOf,
	#category : #BaselineOfThreadedFFIMigration
}

{ #category : #baselines }
BaselineOfThreadedFFIMigration >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec 
			baseline: #ThreadedFFI 
				with: [ spec repository: 'github://feenkcom/threadedFFI-Plugin' ].

		spec 
			package: #'ThreadedFFIMigration'
				with: [ spec requires: #(#ThreadedFFI) ]  ].

]
