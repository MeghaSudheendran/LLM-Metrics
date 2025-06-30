"
A LLMMBlueTest is a test class for testing the behavior of LLMMBlue
"
Class {
	#name : 'LLMMBlueTest',
	#superclass : 'TestCase',
	#instVars : [
		'blue',
		'candidate'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMMBlueTest >> setUp [
	super setUp.

	blue := LLMMBlue new
]

{ #category : 'tests' }
LLMMBlueTest >> testAllNgramsNgramOrder [

	self assert: (blue allNgrams: 'word' ngramOrder: 2) size equals: 0.

	self assert: (blue allNgrams: 'word' ngramOrder: 1) size equals: 1
]

{ #category : 'tests' }
LLMMBlueTest >> testBigramPrecision [

	blue reference: 'the cat is on the mat'.

	self
		assert:
		(blue ngramPrecision: 'the the the the the the the' order: 2)
		equals: 0 / 5.
	self
		assert: (blue ngramPrecision: 'There is a cat on the mat' order: 2)
		equals: 2 / 5
]

{ #category : 'tests' }
LLMMBlueTest >> testBrevityPenalty [

	blue reference: 'the cat is on the mat'.
	candidate := 'the cat the cat on the mat'.
	self assert: (blue brevityPenalty: candidate) equals: 1.


	blue reference: 'I always invariably perpetually do.'.
	candidate := 'I always do'.
	self
		assert: (blue brevityPenalty: candidate)
		equals: 0.11283618731705691
]

{ #category : 'tests' }
LLMMBlueTest >> testCalculateBlueScoreNgramOrder [

	| blueScore |
	blue reference: 'I always invariably perpetually do.'.
	candidate := 'I always invariably perpetually do the things I love to do.'.
	blueScore := blue calculateBlueScore: candidate ngramOrder: 2.

	self assert: blueScore equals: 0.9394418390694239
]

{ #category : 'tests' }
LLMMBlueTest >> testNgramPrecisionOrder [

	blue reference: 'the cat is on the mat'.

	self
		assert:
		(blue ngramPrecision: 'the the the the the the the' order: 3)
		equals: 0 / 4.
	self
		assert: (blue ngramPrecision: 'There is a cat on the mat' order: 3)
		equals: 1 / 4
]

{ #category : 'tests' }
LLMMBlueTest >> testTrigramPrecision [

	blue reference: 'the cat is on the mat'.

	self
		assert:
		(blue ngramPrecision: 'the the the the the the the' order: 3)
		equals: 0 / 4.
	self
		assert: (blue ngramPrecision: 'There is a cat on the mat' order: 3)
		equals: 1 / 4
]

{ #category : 'tests' }
LLMMBlueTest >> testUnigramPrecision [

	blue reference: 'the cat is on the mat'.

	self
		assert:
		(blue ngramPrecision: 'the the the the the the the' order: 1)
		equals: 2 / 6.
	self
		assert: (blue ngramPrecision: 'There is a cat on the mat' order: 1)
		equals: 5 / 6
]
