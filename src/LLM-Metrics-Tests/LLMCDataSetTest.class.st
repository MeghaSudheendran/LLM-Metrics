"
A LLMCDataSetTest is a test class for testing the behavior of LLMCDataSet
"
Class {
	#name : 'LLMCDataSetTest',
	#superclass : 'TestCase',
	#instVars : [
		'llmCDataSet'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMCDataSetTest >> setUp [

	super setUp.

	llmCDataSet := LLMCDataSet new.
	
]

{ #category : 'tests' }
LLMCDataSetTest >> testAllChildrenMatch [

	| candidateRoots referenceRoots fastModelCand visitorCand fastModelRef visitorRef |
	fastModelCand := FASTFortranImporter new onSourceString:
		                 'function foo() result(r)
  									integer :: r
  									r = 1
								end function'.
	visitorCand := llmCDataSet getSubtreeVisitor: fastModelCand.
	candidateRoots := llmCDataSet getSubtreesOfHeight2: visitorCand.

	fastModelRef := FASTFortranImporter new onSourceString:
		                'function foo() result(r)
  									integer :: x
  									x = 99
								end function'.

	visitorRef := llmCDataSet getSubtreeVisitor: fastModelRef.
	referenceRoots := llmCDataSet getSubtreesOfHeight2: visitorRef.

	
	self assert: (candidateRoots size = referenceRoots size and: [
				 (llmCDataSet
					  countMatchedSubtreesIn: candidateRoots
					  and: referenceRoots) = candidateRoots size ])
]

{ #category : 'tests' }
LLMCDataSetTest >> testBrevityPenalty [

	| llmCandidateSet res |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'the the the the the the the').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'the cat is on the mat').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'there is a cat on the mat').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: llmCDataSet brevityPenalty equals: 1.

	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'the the the').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'the cat is on the mat').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'there is a cat on the mat').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.
	res := llmCDataSet brevityPenalty.

	self assert: llmCDataSet brevityPenalty closeTo: 0.40289 precision: 5

	"
min_ref =21
cand= 11
"
]

{ #category : 'tests' }
LLMCDataSetTest >> testBrevityPenalty1 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'A test').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'A test').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'Another test').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: llmCDataSet brevityPenalty equals: 1
]

{ #category : 'tests' }
LLMCDataSetTest >> testBrevityPenalty2 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'A test').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'A test hello').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'Another test longer better?').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'And Another test longer worse!').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: llmCDataSet brevityPenalty equals: -0.5 exp
]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateASTMatchScore [

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
	

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	self
		assert: (llmCDataSet calculateASTMatchScore)
		equals: 1
]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateBlueScore [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'the the the the the the the').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'the cat is on the mat').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'The cat is on the mat.').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.
	self
		assert: (llmCDataSet calculateBlueScore: 1)
		closeTo: 0.28571
		precision: 5.
	self
		assert: (llmCDataSet calculateBlueScore: 2)
		equals: 0.2857142857142857.
	self
		assert: (llmCDataSet calculateBlueScore: 4)
		equals: 0.2857142857142857
]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateBlueScore1 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'This is a test.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'This is a test.').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'This is a test.').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self assert: (llmCDataSet calculateBlueScore: 4) equals: 1.

]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateBlueScore2 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:(llmCandidateSet preprocessData:
		'It is a guide to action which ensures that the military always obeys the commands of the party.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self
		assert: (llmCDataSet calculateBlueScore: 4)
		equals: 0.5045666840058485.
	
]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateBlueScore3 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:(llmCandidateSet preprocessData:
		'It is to insure the troops forever hearing the activity guidebook that party direct.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self
		assert: (llmCDataSet calculateBlueScore: 4)
		equals: 0.18174699151949172.
	
]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateBlueScore4 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'the the the the the the the.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'The cat is on the mat.').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'The cat is on the mat.').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.


	self
		assert: (llmCDataSet calculateBlueScore: 4)
		equals: 0.2857142857142857
]

{ #category : 'tests' }
LLMCDataSetTest >> testCalculateWeightedNgramMatch [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'def sum ( ):').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def product ( ):').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def add ( ):').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	"weighted_precision =(5/6)
	ln precison = -0.1823215567939546
	sum = -0.1823215567939546
	bp=1
	1*(-0.1823215567939546/1)exp
	0.83333
	"
	self
		assert: (llmCDataSet calculateWeightedNgramMatch: 1)
		equals: 0.8333333333333334
]

{ #category : 'tests' }
LLMCDataSetTest >> testGetASTMatchReference [

	| candidate reference |
	candidate := 'INTEGER FUNCTION SIMPLEFUNCTION(a, b)
      	INTEGER :: a, b
      	SIMPLEFUNCTION = a + b
      END'.
	reference := 'INTEGER FUNCTION SIMPLEFUNCTION(a, b)
      	INTEGER :: a, b
      	SIMPLEFUNCTION = a + b
      END'.
	self
		assert: (llmCDataSet getASTMatch: candidate reference: reference) first
		equals: 5
]

{ #category : 'tests' }
LLMCDataSetTest >> testGetScoreForOneAndReferences [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidateSourcecode: 'function foo() result(r)
       integer :: r
       r = 1
     end function'.
	llmCandidateSet referencesSourcecode: OrderedCollection new.
	llmCandidateSet referencesSourcecode add: 'function foo() result(r)
       integer :: r
       r = 42
     end function'.
	llmCandidateSet referencesSourcecode add: 'function foo() result(r)
       integer :: r
       r = 1
     end function'.

	self
		assert: (llmCDataSet
				 getMatchedCountForOneCandidate: llmCandidateSet candidateSourcecode
				 andReferences: llmCandidateSet referencesSourcecode)
		equals: #( 8 8 )
]

{ #category : 'tests' }
LLMCDataSetTest >> testGetSubtreeVisitor [

	| visitor fastModel |
	fastModel := FASTFortranImporter new onSourceString:
		             'function simplefunction(a, b) result(sum)
  								integer, intent(in) :: a, b
  								integer :: sum
  								sum = a + b
      					end function simplefunction'.
	visitor := llmCDataSet getSubtreeVisitor: fastModel.
	self assert: (visitor isKindOf: FASTFortranSubtreeVisitor)
]

{ #category : 'tests' }
LLMCDataSetTest >> testGetSubtreesOfHeight2 [

	| subtrees fastModel visitor |
	fastModel := FASTFortranImporter new onSourceString:
		             'function simplefunction(a, b) result(sum)
  								integer, intent(in) :: a, b
  								integer :: sum
  								sum = a + b
      					end function simplefunction'.
	visitor := llmCDataSet getSubtreeVisitor: fastModel.

	subtrees := llmCDataSet getSubtreesOfHeight2: visitor.
	self assert: subtrees size equals: 6
]

{ #category : 'tests' }
LLMCDataSetTest >> testNoChildrenMatch [

	| candidateRoots referenceRoots fastModelCand visitorCand fastModelRef visitorRef |
	fastModelCand := FASTFortranImporter new onSourceString:
		                 'function foo() result(r)
  									integer :: r
  									r = 1
								end function'.
	visitorCand := llmCDataSet getSubtreeVisitor: fastModelCand.
	candidateRoots := llmCDataSet getSubtreesOfHeight2: visitorCand.

	fastModelRef := FASTFortranImporter new onSourceString:
		                'function foo() result(r)
  									real :: x
  									x = 3.14
									print *, x
								end function'.

	visitorRef := llmCDataSet getSubtreeVisitor: fastModelRef.
	referenceRoots := llmCDataSet getSubtreesOfHeight2: visitorRef.

	self assert:
		candidateRoots first className equals: referenceRoots first className.
	self
		assert: (llmCDataSet
				 countMatchedSubtreesIn: candidateRoots
				 and: referenceRoots)
		equals: 1
]

{ #category : 'tests' }
LLMCDataSetTest >> testOneChildMatch [

	| candidateRoots referenceRoots fastModelCand visitorCand fastModelRef visitorRef |
	fastModelCand := FASTFortranImporter new onSourceString:
		                 'function foo() result(r)
       							integer :: r
       							r = 1
     							end function'.
	visitorCand := llmCDataSet getSubtreeVisitor: fastModelCand.
	candidateRoots := llmCDataSet getSubtreesOfHeight2: visitorCand.

	fastModelRef := FASTFortranImporter new onSourceString:
		                'function foo() result(r)
       							integer :: r
     							end function'.
	visitorRef := llmCDataSet getSubtreeVisitor: fastModelRef.
	referenceRoots := llmCDataSet getSubtreesOfHeight2: visitorRef.
	self
		assert: candidateRoots first className
		equals: referenceRoots first className.
	self
		assert: (llmCDataSet
				 countMatchedSubtreesIn: candidateRoots
				 and: referenceRoots)
		equals: 2
]

{ #category : 'tests' }
LLMCDataSetTest >> testPrecision [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate: (llmCandidateSet preprocessData:'the the the the the the the.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'the cat is on the mat.').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'there is a cat on the mat.').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	self assert: (llmCDataSet precision: 1) equals: 2 / 7.
	self assert: (llmCDataSet precision: 2) equals: 0
]

{ #category : 'tests' }
LLMCDataSetTest >> testPrecision1 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:(llmCandidateSet preprocessData:
		'It is to insure the troops forever hearing the activity guidebook that party direct.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.
	self assert: (llmCDataSet precision: 1) equals: 8 / 14
]

{ #category : 'tests' }
LLMCDataSetTest >> testPrecision2 [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:(llmCandidateSet preprocessData:
		'It is a guide to action which ensures that the military always obeys the commands of the party.').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is a guide to action that ensures that the military will forever heed Party commands.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the guiding principle which guarantees the military forces always being under the command of the Party.').
	llmCandidateSet references add: (llmCandidateSet preprocessData:
			 'It is the practical guide for the army always to heed the directions of the party.').


	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.
	self assert: (llmCDataSet precision: 1) equals: 17 / 18
]

{ #category : 'tests' }
LLMCDataSetTest >> testRootDoesNotMatch [

	| candidateRoots referenceRoots fastModelCand visitorCand fastModelRef visitorRef |
	fastModelCand := FASTFortranImporter new onSourceString:
		                 'function foo() result(r)
  									integer :: r
  									r = 1
								end function'.
	visitorCand := llmCDataSet getSubtreeVisitor: fastModelCand.
	candidateRoots := llmCDataSet getSubtreesOfHeight2: visitorCand.

	fastModelRef := FASTFortranImporter new onSourceString:
		                'subroutine bar()
  									integer :: x
  									x = 2
								end subroutine'.

	visitorRef := llmCDataSet getSubtreeVisitor: fastModelRef.
	referenceRoots := llmCDataSet getSubtreesOfHeight2: visitorRef.

	self assert:
		candidateRoots first className ~= referenceRoots first className.

	self deny: (llmCDataSet
			 subtree: candidateRoots first
			 equals: referenceRoots first)
]

{ #category : 'tests' }
LLMCDataSetTest >> testSubtreeEquals [
	"All children match"

	| candidateRoots referenceRoots fastModelCand visitorCand fastModelRef visitorRef |
	fastModelCand := FASTFortranImporter new onSourceString:
		                 'function simplefunction(a, b) result(sum)
  								integer, intent(in) :: a, b
  								integer :: sum
  								sum = a + b
      					end function simplefunction'.
	visitorCand := llmCDataSet getSubtreeVisitor: fastModelCand.
	candidateRoots := llmCDataSet getSubtreesOfHeight2: visitorCand.

	fastModelRef := FASTFortranImporter new onSourceString:
		                'function simplefunction(x, y) result(sum)
  								integer, intent(in) :: x, y
  								integer :: sum
  								sum = x + y
      					end function simplefunction'.
					
	visitorRef := llmCDataSet getSubtreeVisitor: fastModelRef.
	referenceRoots := llmCDataSet getSubtreesOfHeight2: visitorRef.
	
	self
		assert: candidateRoots first class
		equals: referenceRoots first class.
		
	self assert: (candidateRoots size = referenceRoots size and: [
				 (llmCDataSet
					  countMatchedSubtreesIn: candidateRoots
					  and: referenceRoots) = candidateRoots size ])
]

{ #category : 'tests' }
LLMCDataSetTest >> testSubtreesEqualsRootDoesntMatch [

	| candidateRoots referenceRoots fastModelCand visitorCand fastModelRef visitorRef |
	fastModelCand := FASTFortranImporter new onSourceString:
		                 'function simplefunction(a, b) result(sum)
  								integer, intent(in) :: a, b
  								integer :: sum
  								sum = a + b
      					end function simplefunction'.
	visitorCand := llmCDataSet getSubtreeVisitor: fastModelCand.
	candidateRoots := llmCDataSet getSubtreesOfHeight2: visitorCand.

	fastModelRef := FASTFortranImporter new onSourceString:
		                'SUBROUTINE SIMPLE(a, b, result)
        							INTEGER, INTENT(IN) :: a, b
        							INTEGER, INTENT(OUT) :: result

        							result = a + b
      							END SUBROUTINE SIMPLE'.

	visitorRef := llmCDataSet getSubtreeVisitor: fastModelRef.
	referenceRoots := llmCDataSet getSubtreesOfHeight2: visitorRef.

	self assert: candidateRoots first class ~= referenceRoots first class
]

{ #category : 'tests' }
LLMCDataSetTest >> testWeightedPrecision [

	| llmCandidateSet |
	llmCandidateSet := LLMCandiateSet new.
	llmCandidateSet candidate:(llmCandidateSet preprocessData: 'def sum ( ):').
	llmCandidateSet references: OrderedCollection new.
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def product ( ):').
	llmCandidateSet references add:
		(llmCandidateSet preprocessData: 'def add ( ):').

	llmCDataSet candidateSets: OrderedCollection new.
	llmCDataSet candidateSets add: llmCandidateSet.

	self assert: (llmCDataSet weightedPrecision: 1) equals: 5 / 6
]
