Class {
	#name : 'LLMMBlue',
	#superclass : 'Object',
	#instVars : [
		'reference',
		'ngramOrder',
		'referenceNgrams'
	],
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'running' }
LLMMBlue >> allNgrams: aText [

	| ngramModel |
	ngramModel := (AINgramModel order: ngramOrder) trainOn: { aText }.
	^ngramModel asOrderedCollection reject: [ :ngram | self isBoundaryNgram: ngram ]
]

{ #category : 'running' }
LLMMBlue >> isBoundaryNgram: ngram [

	ngram isEmpty ifTrue: [ ^false ].

	(ngram last = '<s>') ifTrue: [ ^true ].

	^self isBoundaryNgram: ngram history
]

{ #category : 'accessing' }
LLMMBlue >> ngramOrder [

	^ngramOrder 
]

{ #category : 'accessing' }
LLMMBlue >> ngramOrder: anInt [

	ngramOrder := anInt 
]

{ #category : 'running' }
LLMMBlue >> ngramPrecision: candidate [

	| allReferenceNgram occurences |

	allReferenceNgram := referenceNgrams copy.
	occurences := 0.

	(self allNgrams: candidate) do: [ :ngram |
		(allReferenceNgram remove: ngram ifAbsent: [ nil ])
			ifNotNil: [ occurences := occurences + 1 ] ].

	^occurences / (referenceNgrams size)
]

{ #category : 'accessing' }
LLMMBlue >> reference [

	^reference
]

{ #category : 'accessing' }
LLMMBlue >> reference: aText [

	reference := aText.
	referenceNgrams := self allNgrams: aText.
]

{ #category : 'private - accessing' }
LLMMBlue >> referenceNgrams [

	^referenceNgrams
]
