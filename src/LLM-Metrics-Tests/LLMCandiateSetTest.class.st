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

	self assert: (llmcandidateSet countClipWeighted: 1) equals: 5.

	self assert: (llmcandidateSet countClipWeighted: 2) equals: 0
]

{ #category : 'tests' }
LLMCandiateSetTest >> testCountClipWeighted [

	llmcandidateSet references: OrderedCollection new.
	llmcandidateSet references add:
		(llmcandidateSet preprocessData: 'def sum ( ) :').
	llmcandidateSet candidate: 'def product ( ) :'.

	self assert: (llmcandidateSet countClipWeighted: 1) equals: 5.

	self assert: (llmcandidateSet countClipWeighted: 2) equals: 0
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
LLMCandiateSetTest >> testPreprocessData [

	| aString |
	aString := 'Hello, this is some text.'.
	self
		assert: (llmcandidateSet preprocessData: aString)
		equals: #( 'hello' 'this' 'is' 'some' 'text' )
]

{ #category : 'tests' }
LLMCandiateSetTest >> testWeightedCount [

	llmcandidateSet candidate: 'def sum ( ) :'.

	self assert: (llmcandidateSet weightedCount: 1) equals: 6.
	self assert: (llmcandidateSet weightedCount: 2) equals: 5
]
