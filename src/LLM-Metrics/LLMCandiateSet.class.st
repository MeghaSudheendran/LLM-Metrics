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
LLMCandiateSet >> candidate: anObject [

	candidate := anObject
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

{ #category : 'testing' }
LLMCandiateSet >> isBoundaryNgram: ngram [

	ngram isEmpty ifTrue: [ ^ false ].

	ngram last = '<s>' ifTrue: [ ^ true ].

	^ self isBoundaryNgram: ngram history
]

{ #category : 'accessing' }
LLMCandiateSet >> references [

	^ references 
]

{ #category : 'accessing' }
LLMCandiateSet >> references: aCollection [

	references := aCollection
]
