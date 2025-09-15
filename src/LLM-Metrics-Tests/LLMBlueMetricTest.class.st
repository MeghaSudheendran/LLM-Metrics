"
A LLMCDataSetTest is a test class for testing the behavior of LLMCDataSet
"
Class {
	#name : 'LLMBlueMetricTest',
	#superclass : 'TestCase',
	#instVars : [
		'llmCDataSet'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMBlueMetricTest >> setUp [

	super setUp.

	llmCDataSet := LLMDataSet new.
	
]

{ #category : 'tests' }
LLMBlueMetricTest >> testBrevityPenalty [

	| llmCandidateSet res |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'the the the the the the the').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'the cat is on the mat').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'there is a cat on the mat').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: llmCDataSet brevityPenalty equals: 1.

	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'the the the').
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
LLMBlueMetricTest >> testBrevityPenalty1 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'A test').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'A test').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'Another test').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: llmCDataSet brevityPenalty equals: 1
]

{ #category : 'tests' }
LLMBlueMetricTest >> testBrevityPenalty2 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'A test').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'A test hello').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'Another test longer better?').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'And Another test longer worse!').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: llmCDataSet brevityPenalty equals: -0.5 exp
]

{ #category : 'tests' }
LLMBlueMetricTest >> testCalculateBlueScore [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'the the the the the the the').
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
	self
		assert: (llmCDataSet calculateBlueScore: 2)
		equals: 0.2857142857142857.
	self
		assert: (llmCDataSet calculateBlueScore: 4)
		equals: 0.2857142857142857
]

{ #category : 'tests' }
LLMBlueMetricTest >> testCalculateBlueScore1 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'This is a test.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'This is a test.').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'This is a test.').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: (llmCDataSet calculateBlueScore: 4) equals: 1.

]

{ #category : 'tests' }
LLMBlueMetricTest >> testCalculateBlueScore2 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:(llmCandidateSet preprocessData:
		'It is a guide to action which ensures that the military always obeys the commands of the party.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self
		assert: (llmCDataSet calculateBlueScore: 4)
		equals: 0.5045666840058485.
	
]

{ #category : 'tests' }
LLMBlueMetricTest >> testCalculateBlueScore3 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:(llmCandidateSet preprocessData:
		'It is to insure the troops forever hearing the activity guidebook that party direct.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self
		assert: (llmCDataSet calculateBlueScore: 4)
		equals: 0.18174699151949172.
	
]

{ #category : 'tests' }
LLMBlueMetricTest >> testCalculateBlueScore4 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'the the the the the the the.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'The cat is on the mat.').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'The cat is on the mat.').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self
		assert: (llmCDataSet calculateBlueScore: 4)
		equals: 0.2857142857142857
]

{ #category : 'tests' }
LLMBlueMetricTest >> testCalculateWeightedNgramMatch [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'def sum ( ):').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def product ( ):').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def add ( ):').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	"weighted_precision =(5/6)
	ln precison = -0.1823215567939546
	sum = -0.1823215567939546
	bp=1
	1*(-0.1823215567939546/1)exp
	0.83333
	"
	self
		assert: (llmCDataSet calculateWeightedNgramMatch: 1)
		equals: 0.8333333333333334
]

{ #category : 'tests' }
LLMBlueMetricTest >> testPrecision [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'the the the the the the the.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'the cat is on the mat.').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'there is a cat on the mat.').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	self assert: (llmCDataSet precision: 1) equals: 2 / 7.
	self assert: (llmCDataSet precision: 2) equals: 0
]

{ #category : 'tests' }
LLMBlueMetricTest >> testPrecision1 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:(llmCandidateSet preprocessData:
		'It is to insure the troops forever hearing the activity guidebook that party direct.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.
	self assert: (llmCDataSet precision: 1) equals: 8 / 14
]

{ #category : 'tests' }
LLMBlueMetricTest >> testPrecision2 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:(llmCandidateSet preprocessData:
		'It is a guide to action which ensures that the military always obeys the commands of the party.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.
	self assert: (llmCDataSet precision: 1) equals: 17 / 18
]

{ #category : 'tests' }
LLMBlueMetricTest >> testWeightedPrecision [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:(llmCandidateSet preprocessData: 'def sum ( ):').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def product ( ):').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def add ( ):').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	self assert: (llmCDataSet weightedPrecision: 1) equals: 5 / 6
]
