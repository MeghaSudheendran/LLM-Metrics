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

{ #category : 'calculating-bluescore' }
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

{ #category : 'calculating-astmatch' }
LLMCDataSet >> calculateASTMatchScore [
	"Main Function to calculate AST match score for the Metric codeblue"

	| astMatchCount totalCount matchResult |
	astMatchCount := 0.
	totalCount := 0.
	candidateSets do: [ :item |
			matchResult := self
				               getMatchedCountForOneCandidate: item candidateSourcecode
				               andReferences: item referencesSourcecode.
			astMatchCount := astMatchCount + matchResult first.
			totalCount := totalCount + matchResult second ].

	^ astMatchCount / totalCount
]

{ #category : 'calculating-bluescore' }
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

{ #category : 'calculating-astmatch' }
LLMCDataSet >> countMatchedSubtreesIn: candidateSubTreesList and: referenceSubTreesList [
	"compare two lists of subtrees and return the number of match"

	| matchedCount |
	matchedCount := 0.

	referenceSubTreesList do: [ :refTree |
			(candidateSubTreesList anySatisfy: [ :candTree |
				 self subtree: refTree equals: candTree ]) ifTrue: [
				matchedCount := matchedCount + 1 ] ].
	^ matchedCount
]

{ #category : 'calculating-astmatch' }
LLMCDataSet >> getASTFromPath: aPathToSourceCode [

	^ FASTFortranImporter new onFile: aPathToSourceCode
]

{ #category : 'calculating-astmatch' }
LLMCDataSet >> getASTFromString: aSourceCodeString [
	"fastModel from a code "

	^ FASTFortranImporter new onSourceString: aSourceCodeString
]

{ #category : 'calculating-astmatch' }
LLMCDataSet >> getASTMatch: candidate reference: ref [
"function to get matching subtrees from the two list of subtrees and total count"
	| candidateSubtrees referenceSubtrees |
	candidateSubtrees := self getSubtreesOfHeight2: "list of subtrees"
		                     (self getSubtreeVisitor: "FASTFortranSubtreeVisitor"
			                      (self getASTFromString: candidate)). "FASTmodel"
	referenceSubtrees := self getSubtreesOfHeight2:
		                     (self getSubtreeVisitor:
			                      (self getASTFromString: ref)).

	^ Array with: (self
		  countMatchedSubtreesIn: candidateSubtrees
		  and: referenceSubtrees) with: referenceSubtrees size
	
	
]

{ #category : 'calculating-astmatch' }
LLMCDataSet >> getMatchedCountForOneCandidate: candidate andReferences: references [
	"One candidate can have multiple references. this function will accumulate the individual scores"

	| matchedCount totalCount |
	matchedCount := 0.
	totalCount := 0.
	references do: [ :ref |
			matchedCount := matchedCount
			                +
			                (self getASTMatch: candidate reference: ref) first.
			totalCount := totalCount
			              + (self getASTMatch: candidate reference: ref) second ].
	^ Array with: matchedCount with: totalCount
]

{ #category : 'calculating-astmatch' }
LLMCDataSet >> getSubtreeVisitor: aModel [

	| visitor |
	visitor := FASTFortranSubtreeVisitor new.
	visitor visitModel: aModel.
	^ visitor
]

{ #category : 'calculating-astmatch' }
LLMCDataSet >> getSubtreesOfHeight2: visitor [
	^ visitor subtreeRoots
]

{ #category : 'calculating-bluescore' }
LLMCDataSet >> precision: n [
	"This quantity measures how many n-grams in the reference sentence are reproduced by the candidate sentence"

	^ (candidateSets sum: [ :cs | cs countClip: n ])
	  / (candidateSets sum: [ :cs | cs count: n ])
]

{ #category : 'sorting' }
LLMCDataSet >> sortChildren: aSetOfChildren [
	^ aSetOfChildren asSortedCollection: [ :a :b | a className < b className ]
]

{ #category : 'calculating-astmatch' }
LLMCDataSet >> subtree: s1 equals: s2 [
	"check whether 2 subtrees are equal"

	s1 class = s2 class ifFalse: [ ^ false ].
	s1 children size = s2 children size ifFalse: [ ^ false ].

	"children are of type Set. So need to sort."
	(self sortChildren: s1 children)
		with: (self sortChildren: s2 children)
		do: [ :c1 :c2 | c1 class = c2 class ifFalse: [ ^ false ] ].

	^ true
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
