"
A LLMCodeBleuASTTest is a test class for testing the behavior of LLMCodeBleuAST
"
Class {
	#name : 'LLMCodeBleuCountMatchingSubtreesBetweenTest',
	#superclass : 'TestCase',
	#instVars : [
		'llmCDataSet',
		'llmCodeBleuAST'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMCodeBleuCountMatchingSubtreesBetweenTest >> setUp [
	super setUp.

	llmCDataSet := LLMDataSet new.
	llmCodeBleuAST := LLMCodeBleuAST new.
]

{ #category : 'tests' }
LLMCodeBleuCountMatchingSubtreesBetweenTest >> testMatchingSubtreeWithMultipleLevels [

	| subtrees1 subtrees2 matchedCount |
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

	matchedCount := llmCodeBleuAST matchedCount.
	matchedCount := matchedCount
	                +
	                (llmCodeBleuAST
		                 countMatchingSubtreesBetween: subtrees1
		                 and: subtrees2).

	self assert: matchedCount equals: 3
]

{ #category : 'tests' }
LLMCodeBleuCountMatchingSubtreesBetweenTest >> testNoMatchedSubtree [

	| subtrees1 subtrees2 |
	subtrees1 := FASTFortranStatementBlock new
		             addStatement: FASTFortranEntryStatement new;
		             addStatement: FASTFortranExitStatement new;
		             yourself.
		
	subtrees2 := FASTFortranStatementBlock new
		             addStatement: FASTFortranDoStatement new;
		             yourself.


	llmCodeBleuAST
		countMatchingSubtreesBetween: subtrees1
		and: subtrees2.

	self assert: llmCodeBleuAST matchedCount equals: 0
]

{ #category : 'tests' }
LLMCodeBleuCountMatchingSubtreesBetweenTest >> testOneMatchedSubtree [

	| subtrees1 subtrees2 matchedCount |
	subtrees1 := FASTFortranStatementBlock new
		             addStatement: FASTFortranEntryStatement new;
		             addStatement: FASTFortranExitStatement new;
		             yourself.

	subtrees2 := FASTFortranStatementBlock new
		             addStatement: FASTFortranEntryStatement new;
		             addStatement: FASTFortranExitStatement new;
		             yourself.

	matchedCount := llmCodeBleuAST matchedCount.
	matchedCount := matchedCount + (llmCodeBleuAST
		                countMatchingSubtreesBetween: subtrees1
		                and: subtrees2).

	self assert: matchedCount equals: 1
]
