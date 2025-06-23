"
A LLMMBlueTest is a test class for testing the behavior of LLMMBlue
"
Class {
	#name : 'LLMMBlueTest',
	#superclass : 'TestCase',
	#instVars : [
		'blue',
		'ngramModel'
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
LLMMBlueTest >> testAllNgrams [

	blue ngramOrder: 2.
	self assert: (blue allNgrams: 'word') size equals: 0.

	blue ngramOrder: 1.	
	self assert: (blue allNgrams: 'word') size equals: 1
]

{ #category : 'tests' }
LLMMBlueTest >> testBigramPrecision [

	blue ngramOrder: 2.
	blue reference: 'the cat is on the mat'.

	self assert: (blue ngramPrecision: 'the the the the the the the') equals: 0/5.
	self assert: (blue ngramPrecision: 'There is a cat on the mat') equals: 2/5
]

{ #category : 'tests' }
LLMMBlueTest >> testTrigramPrecision [

	blue ngramOrder: 3.
	blue reference: 'the cat is on the mat'.

	self assert: (blue ngramPrecision: 'the the the the the the the') equals: 0/4.
	self assert: (blue ngramPrecision: 'There is a cat on the mat') equals: 1/4
]

{ #category : 'tests' }
LLMMBlueTest >> testUnigramPrecision [

	blue ngramOrder: 1.
	blue reference: 'the cat is on the mat'.

	self assert: (blue ngramPrecision: 'the the the the the the the') equals: 2/6.
	self assert: (blue ngramPrecision: 'There is a cat on the mat') equals: 5/6
]
