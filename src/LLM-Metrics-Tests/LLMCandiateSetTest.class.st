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
LLMCandiateSetTest >> testClippedSum [

	llmcandidateSet references: OrderedCollection new.
	llmcandidateSet references add:
		(llmcandidateSet preprocessData: 'def sum ( ) :').
	llmcandidateSet candidate: 'def product ( ) :'.


	"
    Clipped matches:
    - 'def': 1x in candidate, 1x in reference, weight 5 (if keyword)
    - '(': 1x in candidate, 1x in reference, weight 1
    - ')': 1x in candidate, 1x in reference, weight 1
    - ':': 1x in candidate, 1x in reference, weight 1
    - 'product': 1x in candidate, 0x in reference, weight 1
    "
	"Total: 5 (def) + 1 ( ( ) ) + 1 ( ) ) + 1 ( : ) = 8"

	self assert: (llmcandidateSet clippedSum: 1) equals: 8.
	"
    Clipped matches:
      - '( )' in both, weight 1
      - ') :' in both, weight 1
    Total = 1 + 1 = 2"

	self assert: (llmcandidateSet clippedSum: 2) equals: 2
]

{ #category : 'tests' }
LLMCandiateSetTest >> testCountClip [

	llmcandidateSet references: OrderedCollection new.
	llmcandidateSet references add:
		(llmcandidateSet preprocessData: 'cat running on cat').
	llmcandidateSet references add:
		(llmcandidateSet preprocessData: 'cat kills rat').
	llmcandidateSet references add:
		(llmcandidateSet preprocessData: 'cat chasing on mat').

	llmcandidateSet candidate: 'cat chasing on mat cat'.

	self assert: (llmcandidateSet countClip: 1) equals: 5
]

{ #category : 'tests' }
LLMCandiateSetTest >> testGetWeightOfNgram [

	self
		assert: (LLMCandiateSet new getWeightOfNgram:
				 (AINgram withElements: #( 'cat' ) asOrderedCollection))
		equals: 1.
	self
		assert: (LLMCandiateSet new getWeightOfNgram:
				 (AINgram withElements: #( 'def cat' ) asOrderedCollection))
		equals: 5
]

{ #category : 'tests' }
LLMCandiateSetTest >> testGetWeightedNgramsOrder [

	| reference result ngrams |
	reference := 'def cat dog'.


	result := LLMCandiateSet new getWeightedNgrams: reference order: 2.
	ngrams := LLMCandiateSet new getNgrams: reference order: 2.

	self assert: (result at: ngrams first) equals: 5.
	self assert: (result at: (ngrams at: 2)) equals: 1.
	self assert: result size equals: 2
]

{ #category : 'tests' }
LLMCandiateSetTest >> testPreprocessData [

	| aString |
	aString := 'Hello, this is some text.'.
	self assert: (llmcandidateSet preprocessData: aString) equals: #('hello' 'this' 'is' 'some' 'text')
]

{ #category : 'tests' }
LLMCandiateSetTest >> testWeightedCount [

	llmcandidateSet candidate: 'def sum ( ) :'.
	"def = 5, sum = 1, ( = 1, ) = 1, : = 1"
	"Total = 5 + 1 + 1 + 1 + 1 = 9"

	self assert: (llmcandidateSet weightedCount: 1) equals: 9
]
