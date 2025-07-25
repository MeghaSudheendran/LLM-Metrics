Class {
	#name : 'LLMCandiateSet',
	#superclass : 'Object',
	#instVars : [
		'references',
		'candidate'
	],
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'accessing' }
LLMCandiateSet >> candidate [

	^ candidate
]

{ #category : 'accessing' }
LLMCandiateSet >> candidate: aString [

	candidate := self preprocessData: aString
]

{ #category : 'operations' }
LLMCandiateSet >> clippedSum: n [

	| referenceNgramsCount candidateNgrams grams bags candidateNgramsCount maxCountReference clippedCount minCountRefCand weight |
	clippedCount := 0.
	referenceNgramsCount := OrderedCollection new.
	referenceNgramsCount addAll: (references collect: [ :reference |
				 grams := self getNgrams: reference order: n.
				 bags := Bag withAll: grams.
				 bags ]).

	candidateNgrams := self getNgrams: candidate order: n.
	candidateNgramsCount := Bag withAll: candidateNgrams.

	candidateNgrams asSet do: [ :cand |
			maxCountReference := 0.
			minCountRefCand := candidateNgramsCount occurrencesOf: cand.
			referenceNgramsCount do: [ :ref |
				maxCountReference := maxCountReference max:
					                     (ref occurrencesOf: cand) ].
			minCountRefCand := maxCountReference min: minCountRefCand.
			weight := self getWeightOfNgram: cand.
			clippedCount := clippedCount + (minCountRefCand * weight) ].

	^ clippedCount
]

{ #category : 'accessing' }
LLMCandiateSet >> count: n [

	| candidateNgrams |
	candidateNgrams := self getNgrams: candidate order: n.
	^ candidateNgrams size
]

{ #category : 'operations' }
LLMCandiateSet >> countClip: n [

	| referenceNgramsCount candidateNgrams grams bags candidateNgramsCount maxCountReference clippedCount minCountRefCand |
	clippedCount := 0.
	referenceNgramsCount := OrderedCollection new.
	referenceNgramsCount addAll: (references collect: [ :reference |
				 grams := self getNgrams: reference order: n.
				 bags := Bag withAll: grams.
				 bags ]).

	candidateNgrams := self getNgrams: candidate order: n.
	candidateNgramsCount := Bag withAll: candidateNgrams.

	candidateNgrams asSet do: [ :cand |
			maxCountReference := 0.
			minCountRefCand := candidateNgramsCount occurrencesOf: cand.
			referenceNgramsCount do: [ :ref |
				maxCountReference := maxCountReference max:
					                     (ref occurrencesOf: cand) ].
			minCountRefCand := maxCountReference min: minCountRefCand.
			clippedCount := clippedCount + minCountRefCand ].

	^ clippedCount
]

{ #category : 'operations' }
LLMCandiateSet >> getNgrams: reference order: o [

	| ngramModel |
	ngramModel := (AINgramModel order: o) trainOn: { reference }.
	^ ngramModel asOrderedCollection reject: [ :ngram |
		  self isBoundaryNgram: ngram ]
]

{ #category : 'operations' }
LLMCandiateSet >> getWeightOfNgram: ngram [

	| pythonKeywords tokens |
	pythonKeywords := #( 'False' 'None' 'True' 'and' 'as' 'assert'
	                     'async' 'await' 'break' 'class' 'continue'
	                     'def' 'del' 'elif' 'else' 'except' 'finally'
	                     'for' 'from' 'global' 'if' 'import' 'in' 'is'
	                     'lambda' 'nonlocal' 'not' 'or' 'pass' 'raise'
	                     'return' 'try' 'while' 'with' 'yield' ).



	tokens := ngram asArray flatCollect: [:token |
        token isString
            ifTrue: [ token substrings ]
            ifFalse: [ { token } ] ].
	(tokens anySatisfy: [ :token | pythonKeywords includes: token ])
		ifTrue: [ ^ 5 ]
		ifFalse: [ ^ 1 ]
]

{ #category : 'operations' }
LLMCandiateSet >> getWeightedNgrams: reference order: o [

	| ngramModel ngrams weightedGramDict |
	ngramModel := (AINgramModel order: o) trainOn: { reference }.
	ngrams := ngramModel asOrderedCollection reject: [ :ngram |
		          self isBoundaryNgram: ngram ].

	weightedGramDict := Dictionary new.
	ngrams do: [ :gram |
		weightedGramDict at: gram put: (self getWeightOfNgram: gram) ].
	^ weightedGramDict
]

{ #category : 'testing' }
LLMCandiateSet >> isBoundaryNgram: ngram [

	ngram isEmpty ifTrue: [ ^ false ].

	ngram last = '<s>' ifTrue: [ ^ true ].

	^ self isBoundaryNgram: ngram history
]

{ #category : 'preprocess' }
LLMCandiateSet >> preprocessData: aString [
	^ aString substrings 

	
]

{ #category : 'accessing' }
LLMCandiateSet >> references [

	^ references 
]

{ #category : 'accessing' }
LLMCandiateSet >> references: aCollection [

	references := aCollection
]

{ #category : 'accessing' }
LLMCandiateSet >> weightedCount: n [

	| candidateNgrams candidateNgramsCount sum |
	candidateNgrams := self getNgrams: candidate order: n.
	candidateNgramsCount := Bag withAll: candidateNgrams.
	sum := 0.
	candidateNgrams asSet do: [ :cand |
			sum := sum + ((candidateNgramsCount occurrencesOf: cand)
			        * (self getWeightOfNgram: cand)) ].
	^ sum
]
