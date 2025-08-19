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

	| ratio c r |
	c := 0.
	r := 0.
	candidateSets do: [ :item |
			| min_l_ref |
			"min_l_ref = Float infinity.
			item references do: [ :ref | min_l_ref := min_l_ref min: ref size ]."
			min_l_ref := (item references collect: #size) min.

			r := r + min_l_ref.
			c := c + item candidate size ].

	ratio := r / c.
	c > r
		ifTrue: [ ^ 1 ]
		ifFalse: [ ^ (1 - ratio) exp ]

	"ratio > 1.0
		ifTrue: [ ^ 1 ]
		ifFalse: [ ^ (1 - (1 / ratio)) exp ]"
]

{ #category : 'calculating' }
LLMCDataSet >> calculateBlueScore: maxOrder [

	| sum precision count |
	sum := 0.
	count := 0.
	1 to: maxOrder do: [ :order |
			precision := self precision: order.

			precision > 0 ifTrue: [
					sum := sum + precision ln.
					count := count + 1 ] ].

	^ count = 0
		  ifTrue: [ 0 ]
		  ifFalse: [ self brevityPenalty * (sum / count) exp ]

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

	^(candidateSets sum: [ :cs | cs countClip: n ]) / (candidateSets sum: [ :cs | cs count: n ]).
	"^ Set with: (candidateSets sum: [ :cs | cs countClip: n ]) with: (candidateSets sum: [ :cs | cs count: n ])"
]
