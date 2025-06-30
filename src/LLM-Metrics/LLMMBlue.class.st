Class {
	#name : 'LLMMBlue',
	#superclass : 'Object',
	#instVars : [
		'reference',
		'blueScore',
		'weights'
	],
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'running' }
LLMMBlue >> allNgrams: aText ngramOrder: order [

	| ngramModel |
	ngramModel := (AINgramModel order: order) trainOn: { aText }.
	^ ngramModel asOrderedCollection reject: [ :ngram |
		  self isBoundaryNgram: ngram ]
]

{ #category : 'accessing' }
LLMMBlue >> blueScore [
	^ blueScore 
]

{ #category : 'running' }
LLMMBlue >> brevityPenalty: candidate [

	| brevityPenalty |
	brevityPenalty := candidate size > reference size
		                  ifTrue: [ 1 ]
		                  ifFalse: [
		                  (1 - (reference size / candidate size)) exp ].

	^ brevityPenalty
]

{ #category : 'running' }
LLMMBlue >> calculateBlueScore: candidate ngramOrder: maxOrder [

	| sum |
	sum := 0.
	1 to: maxOrder do: [ :order |
			sum := sum
			       +
			       (1 / maxOrder
			        * (self ngramPrecision: candidate order: order) log) ].


	^ (self brevityPenalty: candidate) * sum exp
]

{ #category : 'running' }
LLMMBlue >> isBoundaryNgram: ngram [

	ngram isEmpty ifTrue: [ ^false ].

	(ngram last = '<s>') ifTrue: [ ^true ].

	^self isBoundaryNgram: ngram history
]

{ #category : 'running' }
LLMMBlue >> ngramPrecision: candidate order: order [

	| allReferenceNgram occurences referenceNgramSize |
	"allReferenceNgram := referenceNgrams copy."
	allReferenceNgram := self allNgrams: reference ngramOrder: order.
	referenceNgramSize := allReferenceNgram size.
	occurences := 0.

	(self allNgrams: candidate ngramOrder: order) do: [ :ngram |
			(allReferenceNgram remove: ngram ifAbsent: [ nil ]) ifNotNil: [
				occurences := occurences + 1 ] ].

	^ occurences / referenceNgramSize
]

{ #category : 'accessing' }
LLMMBlue >> reference [

	^reference
]

{ #category : 'accessing' }
LLMMBlue >> reference: aText [

	reference := aText
	"referenceNgrams := self allNgrams: aText"
]

{ #category : 'accessing' }
LLMMBlue >> weights [

	^ weights
]

{ #category : 'accessing' }
LLMMBlue >> weights: anObject [

	weights := anObject
]
