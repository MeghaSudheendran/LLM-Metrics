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
LLMCodeBleuASTTest >> testCalculateASTMatchScoreFromPaper [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidateSourcecode:
		'function SignCandidate(d) result(s)
  			real, intent(in) :: d
  			real :: s

  			if (d == 0) then
     			s = 0
  			else if (c < 0.0d0) then  
     			s = -1
  			else
     			s = 1
  			end if
		end function SignCandidate'.
		
	llmCandidateSet referencesSourcecode: OrderedCollection new.
	llmCandidateSet referencesSourcecode add:
		'function SignReference(d) result(s)
  			real, intent(in) :: d
  			integer :: s

  			if (d == 0) then
     			s = 0
  			else if (d < 0) then
    			s = -1
  			else
     			s = 1
  			end if
		end function SignReference'.


	llmCodeBleuAST candidateSets: OrderedCollection new.
	llmCodeBleuAST candidateSets add: llmCandidateSet.

	"no of subtree of ref is 9"
	"14/15"
	self assert: llmCodeBleuAST calculateASTMatchScore equals: 14/15.


]

{ #category : 'tests' }
LLMCodeBleuASTTest >> testCalculateASTMatchScoreFromPaper100match [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidateSourcecode:
		'function SignCandidate(d) result(s)
  			integer, intent(in) :: d
  			integer :: s

  			if (d == 0) then
     			s = 0
  			else if (d < 0) then  
     			s = -1
  			else
     			s = 1
  			end if
		end function SignCandidate'.
		
	llmCandidateSet referencesSourcecode: OrderedCollection new.
	llmCandidateSet referencesSourcecode add:
		'function SignReference(c) result(s)
  			integer, intent(in) :: c
  			integer :: s

  			if (c == 0) then
     			s = 0
  			else if (c < 0) then
    			s = -1
  			else
     			s = 1
  			end if
		end function SignReference'.


	llmCodeBleuAST candidateSets: OrderedCollection new.
	llmCodeBleuAST candidateSets add: llmCandidateSet.

	self assert: llmCodeBleuAST calculateASTMatchScore equals: 1.


]

{ #category : 'tests' }
LLMCodeBleuASTTest >> testCalculateASTMatchScoreMultipleReferences [

	| candidate ref1 ref2 count1 count2 totalcount ref3 count3 match |
	candidate := FASTFortranStatementBlock new
		             addStatement: (FASTFortranIfArithmeticStatement new
				              lessLabel: FASTFortranLabelReference new;
				              yourself);
		             addStatement: (FASTFortranIfLogicalStatement new
				              statement: FASTFortranContinueStatement new;
				              yourself);
		             addStatement: (FASTFortranIfBlockStatement new
				              thenStatementBlock: FASTFortranStatementBlock new;
				              yourself);
		             yourself.

	ref1 := FASTFortranIfArithmeticStatement new
		        lessLabel: FASTFortranLabelReference new;
		        yourself.
	ref2 := FASTFortranIfLogicalStatement new
		        statement: FASTFortranContinueStatement new;
		        yourself.
	ref3 := FASTFortranIfBlockStatement new
		        thenStatementBlock: FASTFortranStatementBlock new;
		        yourself.

	count1 := llmCodeBleuAST
		          countMatchingSubtreesBetween: candidate
		          and: ref1.
	count2 := llmCodeBleuAST
		          countMatchingSubtreesBetween: candidate
		          and: ref2.
	count3 := llmCodeBleuAST
		          countMatchingSubtreesBetween: candidate
		          and: ref3.
	match := count1 + count2 + count3.
	totalcount := (llmCodeBleuAST getSubtreesOfHeight2: ref1) size
	              + (llmCodeBleuAST getSubtreesOfHeight2: ref2) size
	              + (llmCodeBleuAST getSubtreesOfHeight2: ref3) size.

	self assert: count1 equals: 1.
	self assert: count2 equals: 1.
	self assert: count3 equals: 0.
	self
		assert: (llmCodeBleuAST getSubtreesOfHeight2: ref1) size
		equals: 1.
	self
		assert: (llmCodeBleuAST getSubtreesOfHeight2: ref2) size
		equals: 1.
	self
		assert: (llmCodeBleuAST getSubtreesOfHeight2: ref3) size
		equals: 0.

	self assert: match equals: 2.
	self assert: totalcount equals: 2.
	self assert: match / totalcount equals: 1
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

	| aSourcecodeString ast |
	aSourcecodeString := 'function foo(x) result(r)
  									integer :: r
  									r = 1
								end function'.

	ast := llmCodeBleuAST getASTFromString: aSourcecodeString.
	self assert: ast class equals: FASTFortranFunction.
	
	self assert: ast parameters isNotEmpty.
	self assert: ast statementBlock isNotNil.

]
