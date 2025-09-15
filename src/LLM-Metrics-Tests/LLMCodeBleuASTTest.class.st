"
A LLMCodeBleuASTTest is a test class for testing the behavior of LLMCodeBleuAST
"
Class {
	#name : 'LLMCodeBleuASTTest',
	#superclass : 'TestCase',
	#instVars : [
		'llmCDataSet',
		'llmCodeBleuAST'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMCodeBleuASTTest >> setUp [

	super setUp.


	llmCDataSet := LLMDataSet new.
	llmCodeBleuAST := LLMCodeBleuAST new
]

{ #category : 'tests' }
LLMCodeBleuASTTest >> testCalculateASTMatchScore [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidateSourcecode:
		'INTEGER FUNCTION SIMPLEFUNCTION(a, b)
      		INTEGER :: a, b
      		SIMPLEFUNCTION = a + b
      END'.
	llmCandidateSet referencesSourcecode: OrderedCollection new.
	llmCandidateSet referencesSourcecode add:
		'INTEGER FUNCTION SIMPLEFUNCTION(a, b)
      		INTEGER :: a, b
      		SIMPLEFUNCTION = a + b
      END'.


	llmCodeBleuAST candidateSets: OrderedCollection new.
	llmCodeBleuAST candidateSets add: llmCandidateSet.

	
	self assert: llmCodeBleuAST calculateASTMatchScore equals: 1.


]

{ #category : 'tests' }
LLMCodeBleuASTTest >> testCalculateASTMatchScoreOneChildMatch [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidateSourcecode: 'function foo() result(r)
       												integer :: r
       												r = 1
     												end function'.
	llmCandidateSet referencesSourcecode: OrderedCollection new.
	llmCandidateSet referencesSourcecode add: 'function foo() result(r)
       														integer :: r
     														end function'.


	llmCodeBleuAST candidateSets: OrderedCollection new.
	llmCodeBleuAST candidateSets add: llmCandidateSet.


	self assert: llmCodeBleuAST calculateASTMatchScore equals: 2/3
]

{ #category : 'tests' }
LLMCodeBleuASTTest >> testCalculateASTMatchScoreRootNotEqualChildrenEqual [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidateSourcecode: 'FUNCTION foo()
  														! Another comment
													END FUNCTION'.
	llmCandidateSet referencesSourcecode: OrderedCollection new.
	llmCandidateSet referencesSourcecode add: 'SUBROUTINE bar()
  																! Another comment
															END SUBROUTINE'.


	llmCodeBleuAST candidateSets: OrderedCollection new.
	llmCodeBleuAST candidateSets add: llmCandidateSet.


	self assert: llmCodeBleuAST calculateASTMatchScore equals: 1/2
]

{ #category : 'tests' }
LLMCodeBleuASTTest >> testCalculateASTMatchScoreWithDepth3 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidateSourcecode: 'SUBROUTINE foo()
													END SUBROUTINE'.
	llmCandidateSet referencesSourcecode: OrderedCollection new.
	llmCandidateSet referencesSourcecode add: 'SUBROUTINE bar()
  																EXIT
															END SUBROUTINE'.


	llmCodeBleuAST candidateSets: OrderedCollection new.
	llmCodeBleuAST candidateSets add: llmCandidateSet.


	self assert: llmCodeBleuAST calculateASTMatchScore equals: 1/2
]

{ #category : 'tests' }
LLMCodeBleuASTTest >> testGetASTFromString [

	| aSourcecodeString |
	aSourcecodeString := 'function foo(x) result(r)
  									integer :: r
  									r = 1
								end function'.

	self
		assert:
		(llmCodeBleuAST getASTFromString: aSourcecodeString) className
		equals: 'FASTFortranFunction'
]
