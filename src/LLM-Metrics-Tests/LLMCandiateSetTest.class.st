"
A LLMCandiateSetTest is a test class for testing the behavior of LLMCandiateSet
"
Class {
	#name : 'LLMCandiateSetTest',
	#superclass : 'TestCase',
	#instVars : [
		'llmcandidateSet'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMCandiateSetTest >> setUp [

	super setUp.
	llmcandidateSet := LLMCandiateSet new.
	

	"Put here a common initialization logic for tests"
]

{ #category : 'tests' }
LLMCandiateSetTest >> testCountClip [

	llmcandidateSet references: OrderedCollection new.
	llmcandidateSet references add: 'cat running on cat'.
	llmcandidateSet references add: 'cat kills rat'.
	llmcandidateSet references add: 'cat chasing on mat'.

	llmcandidateSet candidate: 'cat chasing on mat cat'.

	self assert: (llmcandidateSet countClip: 1) equals: 5
]
