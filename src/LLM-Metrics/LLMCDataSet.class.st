"
LLMCDataset stores objects of LLMCandidateSet. 

It contains methods to calculate BLUE score, WeightedNgramMatch, precision, Brevity penalty etc. 
"
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

{ #category : 'calculating' }
LLMCDataSet >> calculateBlueScore: maxOrder [
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
LLMCDataSet >> calculateWeightedNgramMatch: maxOrder [
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
LLMCDataSet >> candidateSets [

	^ candidateSets
]

{ #category : 'accessing' }
LLMCDataSet >> candidateSets: anObject [

	candidateSets := anObject
]

{ #category : 'calculating' }
LLMCDataSet >> getSubtreesOfHeight2: aPathToSourceCode [

	^ (self getVisitor: aPathToSourceCode) subtreeRoots
]

{ #category : 'calculating' }
LLMCDataSet >> getVisitor: aPathToSourceCode [

	| fastModel visitor |
	fastModel := FASTFortranImporter new onFile: aPathToSourceCode.
	visitor := FASTFortranCountSubtreeVisitorComparing new.
	visitor visitModel: fastModel.
	^ visitor
]

{ #category : 'calculating' }
LLMCDataSet >> precision: n [
	"This quantity measures how many n-grams in the reference sentence are reproduced by the candidate sentence"

	^ (candidateSets sum: [ :cs | cs countClip: n ])
	  / (candidateSets sum: [ :cs | cs count: n ])
]

{ #category : 'calculating' }
LLMCDataSet >> subtrees: subTrees1 equals: subTrees2 [

	| matchedCount |
	matchedCount := 0.
	subTrees1 with: subTrees2 do: [ :s1 :s2 |
			s1 class = s2 class
				ifTrue: [
						s1 children asOrderedCollection
							with: s1 children asOrderedCollection
							do: [ :c1 :c2 | ^ c1 class = c2 class ] ]
				ifFalse: [ ^ matchedCount ] ]
]

{ #category : 'calculating' }
LLMCDataSet >> subtreesMatchedCountIn: subTrees1 and: subTrees2 [

	| matchedCount |
	matchedCount := 0.
	subTrees1 with: subTrees2 do: [ :s1 :s2 |
			s1 class = s2 class ifTrue: [
					s1 children asOrderedCollection
						with: s1 children asOrderedCollection
						do: [ :c1 :c2 |
							c1 class = c2 class ifTrue: [ matchedCount := matchedCount + 1 ] ] ] ].
	^ matchedCount
]

{ #category : 'calculating' }
LLMCDataSet >> weightedPrecision: n [

	| clipped weightedTotal |
	clipped := candidateSets sum: [ :cs |
		           cs countClipWeighted: n ].
	weightedTotal := candidateSets sum: [ :cs | cs weightedCount: n ].
	^ weightedTotal = 0
		  ifTrue: [ 0 ]
		  ifFalse: [ clipped / weightedTotal ]
]
