"
A LLMCodeBleuASTTest is a test class for testing the behavior of LLMCodeBleuAST
"
Class {
	#name : 'LLMCodeBleuCalculateMatchedASTCount',
	#superclass : 'TestCase',
	#instVars : [
		'llmCDataSet',
		'llmCodeBleuAST'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMCodeBleuCalculateMatchedASTCount >> setUp [
	super setUp.

	llmCDataSet := LLMDataSet new.
	llmCodeBleuAST := LLMCodeBleuAST new.
]

{ #category : 'tests' }
LLMCodeBleuCalculateMatchedASTCount >> testMatchingSubtreeWithMultipleLevels [

	| subtrees1 subtrees2 |
	subtrees1 := FASTFortranSubroutine new
		             statementBlock: (FASTFortranStatementBlock new
				              addStatement: FASTFortranEntryStatement new;
				              addStatement: (FASTFortranStatementBlock new
						               addStatement: FASTFortranExitStatement new;
						               yourself);
				              yourself);
		             yourself.
		
	subtrees2 := FASTFortranSubroutine new
		             statementBlock: (FASTFortranStatementBlock new
				              addStatement: FASTFortranEntryStatement new;
				              addStatement: (FASTFortranStatementBlock new
						               addStatement: FASTFortranExitStatement new;
						               yourself);
				              yourself);
		             yourself.
		
		
	llmCodeBleuAST
		calculateMatchedASTCountForaCandidate: subtrees1
		andaReferece: subtrees2.

	self assert: llmCodeBleuAST matchedCount equals: 3
]

{ #category : 'tests' }
LLMCodeBleuCalculateMatchedASTCount >> testNoMatchedSubtree [

	| subtrees1 subtrees2 |
	subtrees1 := FASTFortranStatementBlock new
		             addStatement: FASTFortranEntryStatement new;
		             addStatement: FASTFortranExitStatement new;
		             yourself.
		
	subtrees2 := FASTFortranStatementBlock new
		             addStatement: FASTFortranDoStatement new;
		             yourself.


	llmCodeBleuAST
		calculateMatchedASTCountForaCandidate: subtrees1
		andaReferece: subtrees2.

	self assert: llmCodeBleuAST matchedCount equals: 0
]

{ #category : 'tests' }
LLMCodeBleuCalculateMatchedASTCount >> testOneMatchedSubtree [

	| subtrees1 subtrees2 |
	subtrees1 := FASTFortranStatementBlock new
		             addStatement: FASTFortranEntryStatement new;
		             addStatement: FASTFortranExitStatement new;
		             yourself.
		
	subtrees2 := FASTFortranStatementBlock new
		             addStatement: FASTFortranEntryStatement new;
		             addStatement: FASTFortranExitStatement new;
		             yourself.


	llmCodeBleuAST
		calculateMatchedASTCountForaCandidate: subtrees1
		andaReferece: subtrees2.

	self assert: llmCodeBleuAST matchedCount equals: 1
]
