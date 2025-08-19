"
A LLMCDataSetTest is a test class for testing the behavior of LLMCDataSet
"
Class {
	#name : 'LLMCDataSetTest',
	#superclass : 'TestCase',
	#instVars : [
		'llmCDataSet'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMCDataSetTest >> setUp [

	super setUp.

	llmCDataSet := LLMCDataSet new.
	
]

{ #category : 'tests' }
LLMCDataSetTest >> testBrevityPenalty [

	| llmCandidateSet res |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'the the the the the the the'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'the cat is on the mat').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'there is a cat on the mat').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: llmCDataSet brevityPenalty equals: 1.

	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'the the the'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'the cat is on the mat').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'there is a cat on the mat').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.
	res := llmCDataSet brevityPenalty.

	self assert: llmCDataSet brevityPenalty closeTo: 0.40289 precision: 5

	"
min_ref =21
cand= 11
"
]

{ #category : 'tests' }
LLMCDataSetTest >> testBrevityPenalty1 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'A test'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'A test').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'Another test').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: llmCDataSet brevityPenalty equals: 1.

]

{ #category : 'tests' }
LLMCDataSetTest >> testBrevityPenalty2 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'A test'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'A test hello').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'Another test longer better?').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'And Another test longer worse!').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: llmCDataSet brevityPenalty equals: -0.5 exp.

]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateBlueScore [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'the the the the the the the'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'the cat is on the mat').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'The cat is on the mat.').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.
	self
		assert: (llmCDataSet calculateBlueScore: 1)
		closeTo: 0.28571
		precision: 5.
	self assert: (llmCDataSet calculateBlueScore: 2) equals: 0.2857142857142857.
	self assert: (llmCDataSet calculateBlueScore: 4) equals: 0.2857142857142857.
		
	
]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateBlueScore1 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'This is a test.'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'This is a test.').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'This is a test.').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: (llmCDataSet calculateBlueScore: 4) equals: 1.
	"self
		assert: (llmCDataSet calculateBlueScore: 1)
		closeTo: 0.28571
		precision: 5"
]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateBlueScore2 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:
		'It is a guide to action which ensures that the military always obeys the commands of the party.'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: (llmCDataSet calculateBlueScore: 4) equals: 0.5045666840058485
	"self
		assert: (llmCDataSet calculateBlueScore: 1)
		closeTo: 0.28571
		precision: 5"
]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateBlueScore3 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:
		'It is to insure the troops forever hearing the activity guidebook that party direct.'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: (llmCDataSet calculateBlueScore: 4) equals: 0.18174699151949172
	"self
		assert: (llmCDataSet calculateBlueScore: 1)
		closeTo: 0.28571
		precision: 5"
]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateBlueScore4 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'the the the the the the the.'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'The cat is on the mat.').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'The cat is on the mat.').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: (llmCDataSet calculateBlueScore: 4) equals: 0.2857142857142857.
	"self
		assert: (llmCDataSet calculateBlueScore: 1)
		closeTo: 0.28571
		precision: 5"
]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateWeightedNgramMatch [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'def sum ( ):'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def product ( ):').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def add ( ):').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet

	"self assert: (llmCDataSet calculateWeightedNgramMatch: 1) equals: ?"
]

{ #category : 'tests' }
LLMCDataSetTest >> testModifiedRecall [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'def sum ( ):'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def product ( ):').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def add ( ):').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	self assert: (llmCDataSet modifiedRecall: 1) equals: 7 / 8
]

{ #category : 'tests' }
LLMCDataSetTest >> testPrecision [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'the the the the the the the.'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'the cat is on the mat.').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'there is a cat on the mat.').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	self assert: (llmCDataSet precision: 1) equals: 2 / 7.
	self assert: (llmCDataSet precision: 2) equals: 0.
	

"

	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'the the cat'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'the cat is on the mat').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'there is a cat on the mat').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	self assert: (llmCDataSet precision: 2) equals: 1 / 2"
]

{ #category : 'tests' }
LLMCDataSetTest >> testPrecision1 [

	| llmCandidateSet |
	
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:
		'It is to insure the troops forever hearing the activity guidebook that party direct.'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.
	self assert: (llmCDataSet precision: 1) equals: 8 / 14.
	"self assert: (llmCDataSet precision: 1) equals: (Set with:8 with:14)"

]

{ #category : 'tests' }
LLMCDataSetTest >> testPrecision2 [

	| llmCandidateSet |
	
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:
		'It is a guide to action which ensures that the military always obeys the commands of the party.'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.
	self assert: (llmCDataSet precision: 1) equals: 17 / 18.
	"self assert: (llmCDataSet precision: 1) equals: (Set with:17 with:18)"

]
