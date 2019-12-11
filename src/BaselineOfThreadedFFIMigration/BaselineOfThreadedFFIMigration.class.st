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
			package: #'ThreadedFFIMigration' ].

]
