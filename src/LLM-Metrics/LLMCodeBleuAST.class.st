Class {
	#name : 'LLMCodeBleuAST',
	#superclass : 'LLMDataSet',
	#instVars : [
		'matchedCount',
		'totalCount'
	],
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'calculating-astmatch' }
LLMCodeBleuAST >> calculateASTMatchScore [
	"Main Function to calculate AST match score for the Metric codeblue"
"
	totalCount := 0.
	matchedCount := 0."
	
	candidateSets do: [ :item |
			item referencesSourcecode do: [ :ref || refAST |
				refAST := self getASTFromString: ref.
				matchedCount := matchedCount  +
					(self
						countMatchingSubtreesBetween: (self getASTFromString: item candidateSourcecode)
						and: refAST).
				totalCount := totalCount + (self getSubtreesOfHeight2: refAST) size
			] ].

	^ matchedCount / totalCount
]

{ #category : 'calculating-astmatch' }
LLMCodeBleuAST >> countMatchingSubtreesBetween: aCandidateAST and: aReferenceAST [
	"update matched subtree count and total subtree count"

	| candidateSubTreesList referenceSubTreesList |
	candidateSubTreesList := self getSubtreesOfHeight2: aCandidateAST.
	referenceSubTreesList := self getSubtreesOfHeight2: aReferenceAST.

	^referenceSubTreesList count: [ :refTree |
			candidateSubTreesList anySatisfy: [ :candTree | self subtree: refTree equals: candTree ] ].	
			
]

{ #category : 'calculating-astmatch' }
LLMCodeBleuAST >> getASTFromString: aSourceCodeString [
	"AST from a String "

	^ ((self getModelFromString: aSourceCodeString) select: [ :n |
	 n parents isEmpty ]) first
]

{ #category : 'calculating-astmatch' }
LLMCodeBleuAST >> getModelFromString: aSourceCodeString [
	"fastModel from a code "

	^ FASTFortranImporter new onSourceString: aSourceCodeString
]

{ #category : 'calculating-astmatch' }
LLMCodeBleuAST >> getSubtreeVisitor: anAST [

	| visitor |
	visitor := FASTFortranSubtreeVisitor new.
	anAST accept: visitor.
	^ visitor 
]

{ #category : 'calculating-astmatch' }
LLMCodeBleuAST >> getSubtreesOfHeight2: anAST [

	| visitor |
	anAST ifNil: [ ^ #(  ) ].

	visitor := FASTFortranSubtreeVisitor new.
	anAST accept: visitor.


	^ visitor subtreeRoots
]

{ #category : 'initialization' }
LLMCodeBleuAST >> initialize [

	super initialize.
	totalCount := 0.
	matchedCount := 0
]

{ #category : 'accessing' }
LLMCodeBleuAST >> matchedCount [

	^ matchedCount
]

{ #category : 'accessing' }
LLMCodeBleuAST >> matchedCount: anObject [

	matchedCount := anObject
]

{ #category : 'calculating-astmatch' }
LLMCodeBleuAST >> subtree: s1 equals: s2 [
	"check whether 2 subtrees are equal"

	s1 class = s2 class ifFalse: [ ^ false ].
	s1 children size = s2 children size ifFalse: [ ^ false ].

	"children are of type Set. So need to sort."
	(self sortChildren: s1 children)
		with: (self sortChildren: s2 children)
		do: [ :c1 :c2 | c1 class = c2 class ifFalse: [ ^ false ] ].

	^ true
]

{ #category : 'accessing' }
LLMCodeBleuAST >> totalCount [

	^ totalCount
]

{ #category : 'accessing' }
LLMCodeBleuAST >> totalCount: anObject [

	totalCount := anObject
]
