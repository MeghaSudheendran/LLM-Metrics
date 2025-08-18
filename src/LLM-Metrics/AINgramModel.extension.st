Extension { #name : 'AINgramModel' }

{ #category : '*LLM-Metrics' }
AINgramModel >> asOrderedCollection [

	^ngramCounts asOrderedCollection
]

{ #category : '*LLM-Metrics' }
AINgramModel >> isEmpty [

	^ngramCounts isEmpty
]
