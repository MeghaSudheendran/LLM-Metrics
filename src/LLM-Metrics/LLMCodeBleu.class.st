Class {
	#name : 'LLMCodeBleu',
	#superclass : 'Object',
	#instVars : [
		'llmCDataSet',
		'llmCodeBleuAST'
	],
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'calculating' }
LLMCodeBleu >> computeFinalBleuScoreFor: listOfcandidates against: listOfreferences [

	| alpha beta gamma maxOrder codeBleu |
	alpha := 0.25.
	beta := 0.25.
	gamma := 0.25.
	maxOrder := 4.

	self initDatasetWith: listOfcandidates and: listOfreferences.
	

	codeBleu := alpha * (llmCDataSet calculateBlueScore: maxOrder)
	            +
	            (beta * (llmCDataSet calculateWeightedNgramMatch: maxOrder))
	            + 
					(gamma * (llmCodeBleuAST calculateASTMatchScore)).
	^ codeBleu
]

{ #category : 'calculating' }
LLMCodeBleu >> initDatasetWith: listOfcandidates and: listOfreferences [

	llmCDataSet candidateSets: OrderedCollection new.
	listOfcandidates
		with: listOfreferences
		collect: [ :candidate :references |
				| llmCandidateSet |
				llmCandidateSet := LLMCandiateSet new.

				llmCandidateSet candidateSourcecode: candidate.
				llmCandidateSet referencesSourcecode: references.
				llmCandidateSet references.
				llmCandidateSet candidate.

				llmCDataSet candidateSets add: llmCandidateSet.
				llmCodeBleuAST candidateSets add: llmCandidateSet ]
]

{ #category : 'initialization' }
LLMCodeBleu >> initialize [

	super initialize.
	llmCDataSet := LLMDataSet new.
	llmCodeBleuAST :=LLMCodeBleuAST new.
]
