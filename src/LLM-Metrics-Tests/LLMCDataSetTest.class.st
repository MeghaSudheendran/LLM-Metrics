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
	llmCandidateSet references add: 'the cat is on the mat'.
	llmCandidateSet references add: 'there is a cat on the mat'.

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: llmCDataSet brevityPenalty equals: 1.

	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'the the the'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: 'the cat is on the mat'.
	llmCandidateSet references add: 'there is a cat on the mat'.

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
LLMCDataSetTest >> testCalculateBlueScore [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'the the the the the the the'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: 'the cat is on the mat'.
	llmCandidateSet references add: 'there is a cat on the mat'.

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: (llmCDataSet calculateBlueScore: 2) equals: 0.
	self assert: (llmCDataSet calculateBlueScore: 1) closeTo: 0.28571 precision: 5.
]

{ #category : 'tests' }
LLMCDataSetTest >> testPrecision [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'the the the the the the the'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: 'the cat is on the mat'.
	llmCandidateSet references add: 'there is a cat on the mat'.

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	self assert: (llmCDataSet precision: 1) equals: 2 / 7.
	self assert: (llmCDataSet precision: 2) equals: 0.


	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: 'the the cat'.
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: 'the cat is on the mat'.
	llmCandidateSet references add: 'there is a cat on the mat'.

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	self assert: (llmCDataSet precision: 2) equals: 1 / 2
]
