"
LLMCandidateSet stores candidate texts together with their corresponding references.  
This allows evaluation metrics such as BLEU (and others) to be computed on them.
"
Class {
	#name : 'LLMCandiateSet',
	#superclass : 'Object',
	#instVars : [
		'references',
		'candidate',
		'referencesSourcecode',
		'candidateSourcecode'
	],
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'accessing' }
LLMCandiateSet >> candidate [

	^ candidate ifNil: [
			  self candidateSourcecode
				  ifNil: [ nil ]
				  ifNotNil: [
				  candidate := self preprocessData: self candidateSourcecode ] ]
]

{ #category : 'accessing' }
LLMCandiateSet >> candidate: aString [

	candidate := aString
]

{ #category : 'accessing' }
LLMCandiateSet >> candidateSourcecode [

	^ candidateSourcecode
]

{ #category : 'accessing' }
LLMCandiateSet >> candidateSourcecode: aString [

	candidateSourcecode := aString.
	candidate := nil "invalidate cache"
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
LLMCandiateSet >> countClipWeighted: n [

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

{ #category : 'testing' }
LLMCandiateSet >> isBoundaryNgram: ngram [

	ngram isEmpty ifTrue: [ ^ false ].

	ngram last = '<s>' ifTrue: [ ^ true ].

	^ self isBoundaryNgram: ngram history
]

{ #category : 'preprocess' }
LLMCandiateSet >> preprocessData: aString [

	| sentences cleanedSentences |

	sentences := aString substrings: '.'.

	cleanedSentences := sentences flatCollect: [ :sentence |
			                    sentence substrings
				                    collect: [ :word |
				                    (word select: [ :char | char isAlphaNumeric ])
					                    asLowercase ]
				                    thenSelect: [ :str | str isNotEmpty ] ].

	^ cleanedSentences
]

{ #category : 'accessing' }
LLMCandiateSet >> references [

	^ references ifNil: [
			  references := self referencesSourcecode collect: [ :each |
				                self preprocessData: each ] ]
]

{ #category : 'accessing' }
LLMCandiateSet >> references: aCollection [

	references := aCollection
]

{ #category : 'accessing' }
LLMCandiateSet >> referencesSourcecode [

	^ referencesSourcecode
]

{ #category : 'accessing' }
LLMCandiateSet >> referencesSourcecode: aCollection [

	referencesSourcecode := aCollection.
	references := nil "invalidate cache"
]

{ #category : 'parsing' }
LLMCandiateSet >> tokenize: wordsInAString [
    "Tokenizes a string into words, keeping certain delimiters."
|token_list|
    token_list :=wordsInAString findTokens: ' ;:.,<>[]{}!@#$%^&*()?' 
                                keep: ';:.'',<>[]{}!$?'.

    ^ token_list flattened 

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
