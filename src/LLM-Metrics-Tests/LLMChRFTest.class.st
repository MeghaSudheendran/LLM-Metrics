"
A LLMChRFTest is a test class for testing the behavior of LLMChRF
"
Class {
	#name : 'LLMChRFTest',
	#superclass : 'TestCase',
	#instVars : [
		'llmChRF'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMChRFTest >> setUp [
	super setUp.
	llmChRF := LLMChRF new.
	"Put here a common initialization logic for tests"
]

{ #category : 'tests' }
LLMChRFTest >> testGetCharacterNgramCounts [

	| aString result |
	aString := 'INTEGER FUNCTION SIMPLEFUNCTION(a, b)'.
	result := Set new.
	result := llmChRF getCharacterNgramCounts: aString.

	self assert: result size equals: 4.
	self
		assert: (result at:1) keys
		equals:
			#( 'R' 'G' 'E' 'P' ')' 'U' 'C' 'N' 'a' 'S' 'L' ',' 'F' 'O' '(' 'b'
			   'I' 'M' 'T' ).
			
]

{ #category : 'tests' }
LLMChRFTest >> testGetWordNgramCounts [

	| aString result |
	aString := 'INTEGER FUNCTION SIMPLEFUNCTION(a, b)'.
	result := Set new.
	result := llmChRF getWordNgramCounts: aString.

	self assert: result size equals: 4.


	self
		assert: (result at: 1) keys
		equals: #('b)' 'FUNCTION' 'SIMPLEFUNCTION(a,' 'INTEGER')
		.
	self
		assert: (result at: 2) keys
		equals:
			#('FUNCTION SIMPLEFUNCTION(a,' 'SIMPLEFUNCTION(a, b)' 'INTEGER FUNCTION').
	self
		assert: (result at: 3) keys
		equals: #('FUNCTION SIMPLEFUNCTION(a, b)' 'INTEGER FUNCTION SIMPLEFUNCTION(a,').
	self
		assert: (result at: 4) keys
		equals:
		#('INTEGER FUNCTION SIMPLEFUNCTION(a, b)')
]

{ #category : 'tests' }
LLMChRFTest >> testMatchCountsForCandidateRefForCharNgram [

	| candidate reference result |
	
	candidate := llmChRF getCharacterNgramCounts: 'FUNCTION SUM(a, b)'.
	reference := llmChRF getCharacterNgramCounts:
		             'FUNCTION PRODUCT(a, b)'.

	result := llmChRF matchCountsForCandidate: candidate ref: reference.
	
	
	self assert: (result size) equals:4.
	self assert: (result at: 1) equals: 14.
	self assert: (result at: 2) equals: 11.
	self assert: (result at: 3) equals: 9.
	self assert: (result at: 4) equals: 7.
]

{ #category : 'tests' }
LLMChRFTest >> testMatchCountsForCandidateRefForWordNgram [

	| candidate reference result |
		
	candidate := llmChRF getWordNgramCounts: 'INTEGER FUNCTION SUM(a, b)'.
	reference := llmChRF getWordNgramCounts:
		             'INTEGER FUNCTION PRODUCT(a, b)'.

	result := llmChRF matchCountsForCandidate: candidate ref: reference.

	self assert: (result at: 1) equals: 3.
	self assert: (result at: 2) equals: 1.
	self assert: (result at: 3) equals: 0.
	self assert: (result at: 4) equals: 0.
	
	
]

{ #category : 'tests' }
LLMChRFTest >> testNgramsOfOrderFromTokens [

	| tokens result |
	tokens := OrderedCollection new.
	tokens add: 'INTEGER'.
	tokens add: 'FUNCTION'.
	tokens add: 'SIMPLEFUNCTION(a,'.
	tokens add: 'b)'.


	result := llmChRF ngramsOfOrder: 1 fromTokens: tokens.
	self assert: result size equals: 4.
	self
		assert: result keys
		equals: #( 'b)' 'FUNCTION' 'SIMPLEFUNCTION(a,' 'INTEGER' ).


	result := llmChRF ngramsOfOrder: 2 fromTokens: tokens.
	self assert: result size equals: 3.
	self
		assert: result keys
		equals: #( 'FUNCTION SIMPLEFUNCTION(a,' 'SIMPLEFUNCTION(a, b)'
			   'INTEGER FUNCTION' )
]

{ #category : 'tests' }
LLMChRFTest >> testTotalCandNgramCountRefForCharNgram [

	| candidate reference result |
	candidate := llmChRF getCharacterNgramCounts: 'SUM(a, b)'.
	reference := llmChRF getCharacterNgramCounts:
		             'PRODUCT(a, b)'.


	result := llmChRF totalWordCandNgramCount: candidate ref: reference.

	self assert: (result at: 1) equals: 8.
	self assert: (result at: 2) equals: 7.
	self assert: (result at: 3) equals: 6.
	self assert: (result at: 4) equals: 5
]

{ #category : 'tests' }
LLMChRFTest >> testTotalCandNgramCountRefForWordNgram [

	| candidate reference result |
	candidate := llmChRF getWordNgramCounts: 'INTEGER FUNCTION SUM(a, b)'.
	reference := llmChRF getWordNgramCounts:
		             'INTEGER FUNCTION PRODUCT(a, b)'.


	result := llmChRF totalWordCandNgramCount: candidate ref: reference.

	self assert: (result at: 1) equals: 4.
	self assert: (result at: 2) equals: 3.
	self assert: (result at: 3) equals: 2.
	self assert: (result at: 4) equals: 1
]

{ #category : 'tests' }
LLMChRFTest >> testTotalRefNgramCountRefForCharNgram [

	| candidate reference result |
	candidate := llmChRF getCharacterNgramCounts: 'SUM(a, b)'.
	reference := llmChRF getCharacterNgramCounts:
		             'PRODUCT(a, b)'.


	result := llmChRF totalWordRefNgramCount: candidate ref: reference.

	self assert: (result at: 1) equals: 12.
	self assert: (result at: 2) equals: 11.
	self assert: (result at: 3) equals: 10.
	self assert: (result at: 4) equals: 9
]

{ #category : 'tests' }
LLMChRFTest >> testTotalRefNgramCountRefForWordNgram [

	| candidate reference result |
	candidate := llmChRF getWordNgramCounts: 'INTEGER FUNCTION SUM(a, b)'.
	reference := llmChRF getWordNgramCounts:
		             'INTEGER FUNCTION PRODUCT(a, b)'.


	result := llmChRF totalWordRefNgramCount: candidate ref: reference.

	self assert: (result at: 1) equals: 4.
	self assert: (result at: 2) equals: 3.
	self assert: (result at: 3) equals: 2.
	self assert: (result at: 4) equals: 1
]
