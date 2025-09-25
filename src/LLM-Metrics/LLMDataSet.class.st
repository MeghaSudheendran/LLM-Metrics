"
LLMCDataset stores objects of LLMCandidateSet. 

It contains methods to calculate BLUE score, WeightedNgramMatch, precision, Brevity penalty etc. 
"
Class {
	#name : 'LLMDataSet',
	#superclass : 'Object',
	#instVars : [
		'candidateSets'
	],
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'calculating-bluescore' }
LLMDataSet >> brevityPenalty [
"This function penalizes shorter candidate translations to avoid rewarding incomplete translations."
	| ratio c r |
	c := 0.
	r := 0.
	candidateSets do: [ :item |
			| min_l_ref |
			min_l_ref := (item references collect: #size) min.

			r := r + min_l_ref.
			c := c + item candidate size ].

	ratio := r / c.
	c > r
		ifTrue: [ ^ 1 ]
		ifFalse: [ ^ (1 - ratio) exp ]

	
]

{ #category : 'calculating-bluescore' }
LLMDataSet >> calculateBlueScore: maxOrder [
	"This function evaluates the candidate translation against the reference translations.
It is a weighted geometric mean of all the modified n-gram precisions, multiplied by the brevity penalty.

In the original BLEU paper, the weight w is defined as 1/N, where N is the maximum order. However, since we compute the geometric mean, we cannot simply multiply by 1/N globally. Instead, we count the non-empty precisions and divide by that count."

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
LLMDataSet >> calculateWeightedNgramMatch: maxOrder [
"Compute the weighted n-gram match, where each n-gram precision is multiplied by the weight of its tokens. This gives higher importance to keywords in code compared to ordinary identifiers."

	| sum weightedPrecision count |
	sum := 0.
	count := 0.
	1 to: maxOrder do: [ :order |
			weightedPrecision := self weightedPrecision: order.
			weightedPrecision > 0 ifTrue: [
					sum := sum + weightedPrecision ln.
					count := count + 1 ] ].

	^ count = 0
		  ifTrue: [ 0 ]
		  ifFalse: [ self brevityPenalty * (sum / count) exp ]
]

{ #category : 'accessing' }
LLMDataSet >> candidateSets [

	^ candidateSets
]

{ #category : 'accessing' }
LLMDataSet >> candidateSets: anObject [

	candidateSets := anObject
]

{ #category : 'initialization' }
LLMDataSet >> initialize [

	super initialize.
	candidateSets := OrderedCollection new
]

{ #category : 'calculating-bluescore' }
LLMDataSet >> precision: n [
	"This quantity measures how many n-grams in the reference sentence are reproduced by the candidate sentence"

	^ (candidateSets sum: [ :cs | cs countClip: n ])
	  / (candidateSets sum: [ :cs | cs count: n ])
]

{ #category : 'sorting' }
LLMDataSet >> sortChildren: aSetOfChildren [
	^ aSetOfChildren asSortedCollection: [ :a :b | a className < b className ]
]

{ #category : 'calculating' }
LLMDataSet >> weightedPrecision: n [

	| clipped weightedTotal |
	clipped := candidateSets sum: [ :cs |
		           cs countClipWeighted: n ].
	weightedTotal := candidateSets sum: [ :cs | cs weightedCount: n ].
	^ weightedTotal = 0
		  ifTrue: [ 0 ]
		  ifFalse: [ clipped / weightedTotal ]
]
