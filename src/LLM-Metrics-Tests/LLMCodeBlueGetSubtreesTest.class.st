Class {
	#name : 'LLMCodeBlueGetSubtreesTest',
	#superclass : 'TestCase',
	#instVars : [
		'codeBleuAST'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMCodeBlueGetSubtreesTest >> setUp [
	super setUp.

	codeBleuAST := LLMCodeBleuAST new.
]

{ #category : 'tests' }
LLMCodeBlueGetSubtreesTest >> testChildWithChild [

	| subtrees |
	subtrees := codeBleuAST getSubtreesOfHeight2:
		(FASTFortranStatementBlock new
			addStatement: (FASTFortranVariableDeclarationStatement new
				declaredType: FASTFortranIntegerType new) ;
			yourself ).

	self assert: subtrees isCollection.
	self assert: subtrees size equals: 2
]

{ #category : 'tests' }
LLMCodeBlueGetSubtreesTest >> testEmptyTree [

	| subtrees |
	subtrees := codeBleuAST getSubtreesOfHeight2: nil.

	self assert: subtrees isEmpty
]

{ #category : 'tests' }
LLMCodeBlueGetSubtreesTest >> testHasTwoChildren [

	| subtrees |
	subtrees := codeBleuAST getSubtreesOfHeight2:
		(FASTFortranSubroutine new
			addParameter: FASTFortranScalarVariable new ;
			statementBlock: FASTFortranStatementBlock new ;
			yourself).

	self assert: subtrees isCollection.
	self assert: subtrees size equals: 1
]

{ #category : 'tests' }
LLMCodeBlueGetSubtreesTest >> testNoChild [

	| subtrees |
	subtrees := codeBleuAST getSubtreesOfHeight2: (FASTFortranFunction new).

	self assert: subtrees isCollection.
	self assert: subtrees isEmpty
]

{ #category : 'tests' }
LLMCodeBlueGetSubtreesTest >> testSameOneChild [

	| subtrees |
	subtrees := codeBleuAST getSubtreesOfHeight2:
		            (FASTFortranSubroutine new statementBlock:
			             FASTFortranStatementBlock new).

	self assert: subtrees isCollection.
	self assert: subtrees size equals: 1
]
