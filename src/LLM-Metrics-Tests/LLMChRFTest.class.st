"
A LLMChRFTest is a test class for testing the behavior of LLMChRF
"
Class {
	#name : 'LLMChRFTest',
	#superclass : 'TestCase',
	#instVars : [
		'llmChRF'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMChRFTest >> setUp [
	super setUp.
	llmChRF := LLMChRF new.
	llmChRF beta: 2.
	llmChRF maxCharOrder: 4.
	llmChRF maxWordOrder: 4
	
]

{ #category : 'tests' }
LLMChRFTest >> testCalculateChRF [

	| listOfcandidates listOfreferences chrfFScore |
	listOfcandidates := OrderedCollection with:
		                    'INTEGER FUNCTION SUM(a, b)'.
	listOfreferences := OrderedCollection with: (OrderedCollection
			                     with: 'INTEGER FUNCTION PRODUCT(a, b)'
			                     with: 'INTEGER FUNCTION SUM(a, d)').

	llmChRF initDatasetWith: listOfcandidates and: listOfreferences.

	chrfFScore := llmChRF calculateChRF.

	self assert: chrfFScore closeTo: 0.6983 precision: 4
]

{ #category : 'tests' }
LLMChRFTest >> testCalculateNgramFscoreTotalRefTotalCand [

	| matching totalRef totalCand result |
	matching := Dictionary
		            with: 1 -> 3
		            with: 2 -> 1
		            with: 3 -> 0
		            with: 4 -> 0.
	totalCand := Dictionary
		             with: 1 -> 4
		             with: 2 -> 3
		             with: 3 -> 2
		             with: 4 -> 1.
	totalRef := Dictionary
		            with: 1 -> 4
		            with: 2 -> 3
		            with: 3 -> 2
		            with: 4 -> 1.
	result := llmChRF
		          calculateNgramFscore: matching
		          totalRef: totalRef
		          totalCand: totalCand.
	self assert: (result at: 1) equals: 3 / 4.
	self assert: (result at: 2) equals: 1 / 3.
	self assert: (result at: 3) equals: 1e-16.
	self assert: (result at: 4) equals: 1e-16

	"self assert: result equals: 1.0833 "
]

{ #category : 'tests' }
LLMChRFTest >> testCalculateNgramPrecisionTotalRefTotalCand [

	| matching totalRef totalCand result |
	matching := Dictionary
		            with: 1 -> 3
		            with: 2 -> 1
		            with: 3 -> 0
		            with: 4 -> 0.
	totalCand := Dictionary
		             with: 1 -> 4
		             with: 2 -> 3
		             with: 3 -> 2
		             with: 4 -> 1.
	totalRef := Dictionary
		            with: 1 -> 4
		            with: 2 -> 3
		            with: 3 -> 2
		            with: 4 -> 1.
	result := llmChRF
		          calculateNgramPrecision: matching
		          totalRef: totalRef
		          totalCand: totalCand.
	self assert: (result at: 1) equals: 3 / 4.
	self assert: (result at: 2) equals: 1 / 3.
	self assert: (result at: 3) equals: 0.
	self assert: (result at: 4) equals: 0
]

{ #category : 'tests' }
LLMChRFTest >> testCalculateNgramRecallTotalRefTotalCand [

	| matching totalRef totalCand result |
	matching := Dictionary
		            with: 1 -> 3
		            with: 2 -> 1
		            with: 3 -> 0
		            with: 4 -> 0.
	totalCand := Dictionary
		             with: 1 -> 4
		             with: 2 -> 3
		             with: 3 -> 2
		             with: 4 -> 1.
	totalRef := Dictionary
		            with: 1 -> 4
		            with: 2 -> 3
		            with: 3 -> 2
		            with: 4 -> 1.
	result := llmChRF
		          calculateNgramRecall: matching
		          totalRef: totalRef
		          totalCand: totalCand.
	self assert: (result at: 1) equals: 3 / 4.
	self assert: (result at: 2) equals: 1 / 3.
	self assert: (result at: 3) equals: 0.
	self assert: (result at: 4) equals: 0
]

{ #category : 'tests' }
LLMChRFTest >> testFindBestReferenceMatchForCandidateAgainstReferences [

	| candidate references result |
	candidate := 'INTEGER FUNCTION SUM(a, b)'.
	references := OrderedCollection
		              with: 'INTEGER FUNCTION PRODUCT(a, b)'
		              with: 'INTEGER FUNCTION SUM(a, c)'.

	result := llmChRF
		          findBestReferenceMatchForCandidate: candidate
		          againstReferences: references.

	self assert: (result at:'sentF') closeTo: 0.6983 precision: 4
]

{ #category : 'tests' }
LLMChRFTest >> testGetCharacterNgramCounts [

	| aString result |
	aString := 'INTEGER FUNCTION SIMPLEFUNCTION(a, b)'.
	result := Set new.
	result := llmChRF getCharacterNgramCounts: aString.

	self assert: result size equals: 4.
	self
		assert: (result at:1) keys
		equals:
			#( 'R' 'G' 'E' 'P' ')' 'U' 'C' 'N' 'a' 'S' 'L' ',' 'F' 'O' '(' 'b'
			   'I' 'M' 'T' ).
			
]

{ #category : 'tests' }
LLMChRFTest >> testGetWordNgramCounts [

	| aString result |
	aString := 'INTEGER FUNCTION SIMPLEFUNCTION(a, b).'.
	result := Set new.
	result := llmChRF getWordNgramCounts: aString.

	self assert: result size equals: 4.

	self
		assert: (result at: 1) keys
		equals: #( 'FUNCTION' 'SIMPLEFUNCTION(a' 'INTEGER' ',' '.' 'b)' ).
	self
		assert: (result at: 2) keys
		equals: #( 'FUNCTION SIMPLEFUNCTION(a' ', b)' 'INTEGER FUNCTION'
			   'b) .' 'SIMPLEFUNCTION(a ,' ).

	self
		assert: (result at: 3) keys
		equals:
			#( 'SIMPLEFUNCTION(a , b)' ', b) .' 'INTEGER FUNCTION SIMPLEFUNCTION(a'
			   'FUNCTION SIMPLEFUNCTION(a ,' ).

	self
		assert: (result at: 4) keys
		equals: #( 'INTEGER FUNCTION SIMPLEFUNCTION(a ,'
			   'FUNCTION SIMPLEFUNCTION(a , b)'
			   'SIMPLEFUNCTION(a , b) .' )
]

{ #category : 'tests' }
LLMChRFTest >> testMatchCountsForCandidateRefForCharNgram [

	| candidate reference result |
	candidate := llmChRF getCharacterNgramCounts: 'FUNCTION SUM(a, b)'.
	reference := llmChRF getCharacterNgramCounts:
		             'FUNCTION PRODUCT(a, b)'.


	result := llmChRF matchCountsForCandidate: candidate ref: reference.


	self assert: result size equals: 4.
	self assert: (result at: 1) equals: 14.
	self assert: (result at: 2) equals: 11.
	self assert: (result at: 3) equals: 9.
	self assert: (result at: 4) equals: 7
]

{ #category : 'tests' }
LLMChRFTest >> testMatchCountsForCandidateRefForWordNgram [

	| candidate reference result |
	candidate := llmChRF getWordNgramCounts: 'INTEGER FUNCTION SUM(a, b)'.
	reference := llmChRF getWordNgramCounts:
		             'INTEGER FUNCTION PRODUCT(a, b)'.

	result := llmChRF matchCountsForCandidate: candidate ref: reference.

	self assert: (result at: 1) equals: 5.
	self assert: (result at: 2) equals: 3.
	self assert: (result at: 3) equals: 1.
	self assert: (result at: 4) equals: 0
]

{ #category : 'tests' }
LLMChRFTest >> testNgramsOfOrderFromTokens [

	| tokens result |
	tokens := OrderedCollection new.
	tokens add: 'INTEGER'.
	tokens add: 'FUNCTION'.
	tokens add: 'SIMPLEFUNCTION(a,'.
	tokens add: 'b)'.


	result := llmChRF ngramsOfOrder: 1 fromTokens: tokens.
	self assert: result size equals: 4.
	self
		assert: result keys
		equals: #( 'b)' 'FUNCTION' 'SIMPLEFUNCTION(a,' 'INTEGER' ).


	result := llmChRF ngramsOfOrder: 2 fromTokens: tokens.
	self assert: result size equals: 3.
	self
		assert: result keys
		equals: #( 'FUNCTION SIMPLEFUNCTION(a,' 'SIMPLEFUNCTION(a, b)'
			   'INTEGER FUNCTION' )
]

{ #category : 'tests' }
LLMChRFTest >> testScoreCandidateWordNgramsCharNgramsAgainstReference [
	"candidate := llmChRF getWordNgramCounts: 'SUM(a, b)'.
	reference := llmChRF getWordNgramCount: 'PRODUCT(a, b)'.
"

	| wordMatching wordTotalRef wordNgramCount_candidate charNgramCount_candidate candidate reference match |
	candidate := 'INTEGER FUNCTION SUM(a, b)'.
	reference := 'INTEGER FUNCTION PRODUCT(a, b)'.

	wordNgramCount_candidate := Dictionary
		                            with: 1 -> (Dictionary
				                             with: 'FUNCTION' -> 1
				                             with: 'INTEGER' -> 1
				                             with: 'SUM(a,' -> 1)
		                            with: 2 -> (Dictionary
				                             with: 'FUNCTION SUM(a,' -> 1
				                             with: 'INTEGER FUNCTION' -> 1
				                             with: 'SUM(a, b)' -> 1)
		                            with: 3 -> (Dictionary
				                             with: 'FUNCTION SUM(a, b)' -> 1
				                             with: 'INTEGER FUNCTION SUM(a,' -> 1)
		                            with:
		                            4
		                            ->
		                            (Dictionary with:
			                             'INTEGER FUNCTION SUM(a, b)' -> 1).

	charNgramCount_candidate := Dictionary new
		                            at: 1 put: (Dictionary newFrom: {
						                             ('(' -> 1).
						                             (')' -> 1).
						                             (',' -> 1).
						                             ('C' -> 1).
						                             ('E' -> 2).
						                             ('F' -> 1).
						                             ('G' -> 1).
						                             ('I' -> 2).
						                             ('M' -> 1).
						                             ('N' -> 3).
						                             ('O' -> 1).
						                             ('R' -> 1).
						                             ('S' -> 1).
						                             ('T' -> 2).
						                             ('U' -> 2).
						                             ('a' -> 1).
						                             ('b' -> 1) });
		                            at: 2 put: (Dictionary newFrom: {
						                             ('(a' -> 1).
						                             (',b' -> 1).
						                             ('CT' -> 1).
						                             ('EG' -> 1).
						                             ('ER' -> 1).
						                             ('FU' -> 1).
						                             ('GE' -> 1).
						                             ('IN' -> 1).
						                             ('IO' -> 1).
						                             ('M(' -> 1).
						                             ('NC' -> 1).
						                             ('NS' -> 1).
						                             ('NT' -> 1).
						                             ('ON' -> 1).
						                             ('RF' -> 1).
						                             ('SU' -> 1).
						                             ('TE' -> 1).
						                             ('TI' -> 1).
						                             ('UM' -> 1).
						                             ('UN' -> 1).
						                             ('a,' -> 1).
						                             ('b)' -> 1) });
		                            at: 3 put: (Dictionary newFrom: {
						                             ('(a,' -> 1).
						                             (',b)' -> 1).
						                             ('CTI' -> 1).
						                             ('EGE' -> 1).
						                             ('ERF' -> 1).
						                             ('FUN' -> 1).
						                             ('GER' -> 1).
						                             ('INT' -> 1).
						                             ('ION' -> 1).
						                             ('M(a' -> 1).
						                             ('NCT' -> 1).
						                             ('NSU' -> 1).
						                             ('NTE' -> 1).
						                             ('ONS' -> 1).
						                             ('RFU' -> 1).
						                             ('SUM' -> 1).
						                             ('TEG' -> 1).
						                             ('TIO' -> 1).
						                             ('UM(' -> 1).
						                             ('UNC' -> 1).
						                             ('a,b' -> 1) });
		                            at: 4 put: (Dictionary newFrom: {
						                             ('(a,b' -> 1).
						                             ('CTIO' -> 1).
						                             ('EGER' -> 1).
						                             ('ERFU' -> 1).
						                             ('FUNC' -> 1).
						                             ('GERF' -> 1).
						                             ('INTE' -> 1).
						                             ('IONS' -> 1).
						                             ('M(a,' -> 1).
						                             ('NCTI' -> 1).
						                             ('NSUM' -> 1).
						                             ('NTEG' -> 1).
						                             ('ONSU' -> 1).
						                             ('RFUN' -> 1).
						                             ('SUM(' -> 1).
						                             ('TEGE' -> 1).
						                             ('TION' -> 1).
						                             ('UM(a' -> 1).
						                             ('UNCT' -> 1).
						                             ('a,b)' -> 1) });
		                            yourself.
	match := llmChRF
		         scoreCandidate: candidate
		         wordNgrams: wordNgramCount_candidate
		         charNgrams: charNgramCount_candidate
		         againstReference: reference.

	self assert: (match at: 'sentF') closeTo: 0.4550 precision: 4
]

{ #category : 'tests' }
LLMChRFTest >> testTotalCandNgramCountRefForCharNgram [

	| candidate reference result |
	candidate := llmChRF getCharacterNgramCounts: 'SUM(a, b)'.
	reference := llmChRF getCharacterNgramCounts:
		             'PRODUCT(a, b)'.


	result := llmChRF totalCandNgramCount: candidate ref: reference.

	self assert: (result at: 1) equals: 8.
	self assert: (result at: 2) equals: 7.
	self assert: (result at: 3) equals: 6.
	self assert: (result at: 4) equals: 5
]

{ #category : 'tests' }
LLMChRFTest >> testTotalCandNgramCountRefForWordNgram [

	| candidate reference result |
	candidate := llmChRF getWordNgramCounts: 'INTEGER FUNCTION SUM(a, b)'.
	reference := llmChRF getWordNgramCounts:
		             'INTEGER FUNCTION PRODUCT(a, b)'.

	result := llmChRF totalCandNgramCount: candidate ref: reference.

	self assert: (result at: 1) equals: 6.
	self assert: (result at: 2) equals: 5.
	self assert: (result at: 3) equals: 4.
	self assert: (result at: 4) equals: 3
]

{ #category : 'tests' }
LLMChRFTest >> testTotalRefNgramCountRefForCharNgram [

	| candidate reference result |
	candidate := llmChRF getCharacterNgramCounts: 'SUM(a, b)'.
	reference := llmChRF getCharacterNgramCounts:
		             'PRODUCT(a, b)'.


	result := llmChRF totalRefNgramCount: candidate ref: reference.

	self assert: (result at: 1) equals: 12.
	self assert: (result at: 2) equals: 11.
	self assert: (result at: 3) equals: 10.
	self assert: (result at: 4) equals: 9
]

{ #category : 'tests' }
LLMChRFTest >> testTotalRefNgramCountRefForWordNgram [

	| candidate reference result |
	candidate := llmChRF getWordNgramCounts: 'INTEGER FUNCTION SUM(a, b)'.
	reference := llmChRF getWordNgramCounts:
		             'INTEGER FUNCTION PRODUCT(a, b)'.

	result := llmChRF totalRefNgramCount: candidate ref: reference.

	self assert: (result at: 1) equals: 6.
	self assert: (result at: 2) equals: 5.
	self assert: (result at: 3) equals: 4.
	self assert: (result at: 4) equals: 3
]
