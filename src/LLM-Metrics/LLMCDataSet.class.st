Class {
	#name : 'LLMCDataSet',
	#superclass : 'Object',
	#instVars : [
		'candidateSets'
	],
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'calculating' }
LLMCDataSet >> brevityPenalty [

	| reference_length translation_length ratio |
	translation_length := 0.
	reference_length := 0.
	candidateSets do: [ :item |
			| min_l_ref |
			"min_l_ref = Float infinity.
			item references do: [ :ref | min_l_ref := min_l_ref min: ref size ]."
			min_l_ref := (item references collect: #size) min.

			reference_length := reference_length + min_l_ref.
			translation_length := translation_length + item candidate size ].

	ratio := translation_length / reference_length.
	ratio > 1.0
		ifTrue: [ ^ 1 ]
		ifFalse: [ ^ (1 - (1 / ratio)) exp ]
]

{ #category : 'calculating' }
LLMCDataSet >> calculateBlueScore: maxOrder [

	| sum |
	sum := 0.
	1 to: maxOrder do: [ :order |
	sum := sum + (1 / maxOrder * (self precision: order) ln) ].


	^ self brevityPenalty * sum exp
	


"precision=2/7 for unigram."
]

{ #category : 'calculating' }
LLMCDataSet >> calculateWeightedNgramMatch: maxOrder [

	| sum |
	sum := 0.
	1 to: maxOrder do: [ :order |
		sum := sum + (1.0 / maxOrder * (self modifiedRecall: order) ln) ].


	^ self brevityPenalty * sum exp
]

{ #category : 'accessing' }
LLMCDataSet >> candidateSets [

	^ candidateSets
]

{ #category : 'accessing' }
LLMCDataSet >> candidateSets: anObject [

	candidateSets := anObject
]

{ #category : 'calculating' }
LLMCDataSet >> modifiedRecall: n [

	| clipped weightedTotal |
	clipped := candidateSets sum: [ :cs |
		           cs clippedSum: n ].
	weightedTotal := candidateSets sum: [ :cs | cs weightedCount: n ].
	^ weightedTotal = 0
		  ifTrue: [ 0 ]
		  ifFalse: [ clipped / weightedTotal ]
]

{ #category : 'calculating' }
LLMCDataSet >> precision: n [

	^(candidateSets sum: [ :cs | cs countClip: n ]) / (candidateSets sum: [ :cs | cs count: n ])
]
