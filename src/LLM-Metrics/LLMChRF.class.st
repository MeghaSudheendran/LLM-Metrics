Class {
	#name : 'LLMChRF',
	#superclass : 'LLMDataSet',
	#instVars : [
		'maxWordOrder',
		'maxCharOrder',
		'beta'
	],
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'as yet unclassified' }
LLMChRF >> accumulateDict: targetDict with: sourceDict [
    sourceDict keysAndValuesDo: [ :key :value |
        targetDict at: key put: (targetDict at: key ifAbsent: [0]) + value ]
]

{ #category : 'as yet unclassified' }
LLMChRF >> accumulateDocumentStats: docStats withBestMatch: bestMatch [

	self
		accumulateDict: (docStats at: #wordMatching)
		with: (bestMatch at: #wordMatching).
	self
		accumulateDict: (docStats at: #wordRef)
		with: (bestMatch at: #wordRef).
	self
		accumulateDict: (docStats at: #wordCand)
		with: (bestMatch at: #wordCand).

	self
		accumulateDict: (docStats at: #chrMatching)
		with: (bestMatch at: #chrMatching).
	self
		accumulateDict: (docStats at: #chrRef)
		with: (bestMatch at: #chrRef).
	self
		accumulateDict: (docStats at: #chrCand)
		with: (bestMatch at: #chrCand)
]

{ #category : 'accessing' }
LLMChRF >> beta [

	^ beta
]

{ #category : 'accessing' }
LLMChRF >> beta: anObject [

	beta := anObject
]

{ #category : 'as yet unclassified' }
LLMChRF >> calculateChRF [

	| docStats finalScores |
	docStats := self initializeDocumentStats.

	candidateSets do: [ :item |
			| candidate references bestMatch |
			candidate := item candidateSourcecode.
			references := item referencesSourcecode.

			bestMatch := self
				             findBestReferenceMatchForCandidate: candidate
				             againstReferences: references.

			self accumulateDocumentStats: docStats withBestMatch: bestMatch ].
	finalScores := self computeFinalScoresFrom: docStats.
	^ finalScores at: 'totalFScore'
]

{ #category : 'as yet unclassified' }
LLMChRF >> calculateChRF_Unused [

	| docStats |
	docStats := self initializeDocumentStats.

	candidateSets do: [ :item |
			| candidate references bestMatch |
			candidate := item candidateSourcecode.
			references := item referencesSourcecode.

			bestMatch := self
				             findBestReferenceMatchForCandidate: candidate
				             againstReferences: references.

			self accumulateDocumentStats: docStats withBestMatch: bestMatch ].

	^ self computeFinalScoresFrom: docStats

	"| doc_totalWordMatchingCount doc_totalWordRefCount doc_totalWordCandCount doc_totalChrMatchingCount doc_totalChrRefCount doc_totalChrCandCount totalWordNgramFScore totalwordNgramPrecision totalwordNgramRecall totalCharacterNgramFScore totalCharacterNgramPrecision totalCharacterNgramRecall totalFScore totalPrecision totalRecall |
	candidateSets do: [ :item |
			| candidate references maxF wordNgramCount_candidate charNgramCount_candidate wordNgramCount_reference charNgramCount_reference bestWordMatchingCount bestWordRefCount bestWordCandCount bestChrMatchingCount bestChrRefCount bestChrCandCount |
			bestWordMatchingCount := Dictionary new.
			bestWordRefCount := Dictionary new.
			bestWordCandCount := Dictionary new.
			bestChrMatchingCount := Dictionary new.
			bestChrRefCount := Dictionary new.
			bestChrCandCount := Dictionary new.


			candidate := item candidateSourcecode.
			references := item referencesSourcecode.
			maxF := 0.

			wordNgramCount_candidate := self getWordNgramCounts: candidate.
			charNgramCount_candidate := self getCharacterNgramCounts: candidate.

			references do: [ :reference |
					| characterNgramFScore characterNgramPrecision characterNgramRecall wordNgramRecall wordNgramPrecision wordNgramFScore totalChrRefNgramCount totalChrCandNgramCount matchingChrNgramCounts totalWordCandNgramCount totalWordRefNgramCount matchingWordNgramCounts sentF |
					wordNgramCount_reference := self getWordNgramCounts: reference.
					charNgramCount_reference := self getCharacterNgramCounts:
						                            reference.
					matchingWordNgramCounts := self
						                           matchCountsForCandidate:
						                           wordNgramCount_candidate
						                           ref: wordNgramCount_reference.
					totalWordRefNgramCount := self
						                          totalWordRefNgramCount:
						                          wordNgramCount_candidate
						                          ref: wordNgramCount_reference.
					totalWordCandNgramCount := self
						                           totalWordCandNgramCount:
						                           wordNgramCount_candidate
						                           ref: wordNgramCount_reference.

					matchingChrNgramCounts := self
						                          matchCountsForCandidate:
						                          charNgramCount_candidate
						                          ref: charNgramCount_reference.
					totalChrRefNgramCount := self
						                         totalWordRefNgramCount:
						                         charNgramCount_candidate
						                         ref: charNgramCount_reference.
					totalChrCandNgramCount := self
						                          totalWordCandNgramCount:
						                          charNgramCount_candidate
						                          ref: charNgramCount_reference.


					"" will return wordNgramF, wordNgramRec, wordNgramPrec""

					wordNgramFScore := self
						                   calculateNgramFscore: matchingWordNgramCounts
						                   totalRef: totalWordRefNgramCount
						                   totalCand: totalWordCandNgramCount.
					wordNgramPrecision := self
						                      calculateNgramPrecision:
						                      matchingWordNgramCounts
						                      totalRef: totalWordRefNgramCount
						                      totalCand: totalWordCandNgramCount.
					wordNgramRecall := self
						                   calculateNgramRecall: matchingWordNgramCounts
						                   totalRef: totalWordRefNgramCount
						                   totalCand: totalWordCandNgramCount.

					characterNgramFScore := self
						                        calculateNgramFscore:
						                        matchingChrNgramCounts
						                        totalRef: totalChrRefNgramCount
						                        totalCand: totalChrCandNgramCount.
					characterNgramPrecision := self
						                           calculateNgramPrecision:
						                           matchingChrNgramCounts
						                           totalRef: totalChrRefNgramCount
						                           totalCand: totalChrCandNgramCount.
					characterNgramRecall := self
						                        calculateNgramRecall:
						                        matchingChrNgramCounts
						                        totalRef: totalChrRefNgramCount
						                        totalCand: totalChrCandNgramCount.


					sentF := wordNgramFScore values sum
					         + characterNgramFScore values sum
					         / (maxWordOrder + maxCharOrder).

					maxF > sentF ifTrue: [
							maxF := sentF.
							bestWordMatchingCount := matchingWordNgramCounts.
							bestWordRefCount := totalWordRefNgramCount.
							bestWordCandCount := totalWordCandNgramCount.

							bestChrMatchingCount := matchingChrNgramCounts.
							bestChrRefCount := totalChrRefNgramCount.
							bestChrCandCount := totalChrCandNgramCount ] ].


			""collect document level ngram counts""

			doc_totalWordMatchingCount := self
				                              collectDocumentLevelTotalWordMatchingCountWith:
				                              bestWordMatchingCount.
			doc_totalWordRefCount := self
				                         collectDocumentLevelTotalWordRefCountWith:
				                         bestWordRefCount.
			doc_totalWordCandCount := self
				                          collectDocumentLevelTotalWordCandCountWith:
				                          bestWordCandCount.

			doc_totalChrMatchingCount := self
				                             collectDocumentLevelCharMatchingCountWith:
				                             bestChrMatchingCount.
			doc_totalChrRefCount := self collectDocumentLevelCharRefCountWith:
				                        bestChrRefCount.
			doc_totalChrCandCount := self
				                         collectDocumentLevelCharCandCountWith:
				                         bestChrCandCount ].
	totalWordNgramFScore := self
		                        calculateNgramFscore:
		                        doc_totalWordMatchingCount
		                        totalRef: doc_totalWordRefCount
		                        totalCand: doc_totalWordCandCount.
	totalwordNgramPrecision := self
		                           calculateNgramPrecision:
		                           doc_totalWordMatchingCount
		                           totalRef: doc_totalWordRefCount
		                           totalCand: doc_totalWordCandCount.
	totalwordNgramRecall := self
		                        calculateNgramRecall:
		                        doc_totalWordMatchingCount
		                        totalRef: doc_totalWordRefCount
		                        totalCand: doc_totalWordCandCount.
	totalCharacterNgramFScore := self
		                             calculateNgramFscore:
		                             doc_totalChrMatchingCount
		                             totalRef: doc_totalChrRefCount
		                             totalCand: doc_totalChrCandCount.
	totalCharacterNgramPrecision := self
		                                calculateNgramPrecision:
		                                doc_totalChrMatchingCount
		                                totalRef: doc_totalChrRefCount
		                                totalCand: doc_totalChrCandCount.
	totalCharacterNgramRecall := self
		                             calculateNgramRecall:
		                             doc_totalChrMatchingCount
		                             totalRef: doc_totalChrRefCount
		                             totalCand: doc_totalChrCandCount.

	totalFScore := totalWordNgramFScore values sum
	               + totalCharacterNgramFScore values sum
	               / (maxWordOrder + maxCharOrder).
	totalPrecision := totalwordNgramPrecision values sum
	                  + totalCharacterNgramPrecision values sum
	                  / (maxWordOrder + maxCharOrder).
	totalRecall := totalwordNgramRecall values sum
	               + totalCharacterNgramRecall values sum
	               / (maxWordOrder + maxCharOrder)"
]

{ #category : 'as yet unclassified' }
LLMChRF >> calculateNgramFscore: matching totalRef: totalRef totalCand: totalCand [

	| ngramF factor numerator |
	ngramF := Dictionary new.
	factor := beta squared. "beta**2"

	matching keysAndValuesDo: [ :order :matchCount |
			| prec rec denom |
			prec := (totalCand at: order ifAbsent: [ 0 ]) > 0 ifTrue: [
				        matchCount / (totalCand at: order) ].

			rec := (totalRef at: order ifAbsent: [ 0 ]) > 0 ifTrue: [
				       matchCount / (totalRef at: order) ].

			denom := factor * prec + rec.
			numerator := (1 + factor) * prec * rec.
			ngramF at: order put: (denom > 0
					 ifTrue: [ numerator / denom ]
					 ifFalse: [ 1e-16 ]) ].

	^ ngramF
]

{ #category : 'as yet unclassified' }
LLMChRF >> calculateNgramPrecision: matching totalRef: totalRef totalCand: totalCand [

	| ngramPrec factor |
	ngramPrec := Dictionary new.
	factor := beta squared. 

	matching keysAndValuesDo: [ :order :matchCount |
			| prec |
			prec := (totalCand at: order ifAbsent: [ 0 ]) > 0
				        ifTrue: [ matchCount / (totalCand at: order) ].
			ngramPrec at: order put: prec ].

	^ ngramPrec
]

{ #category : 'as yet unclassified' }
LLMChRF >> calculateNgramRecall: matching totalRef: totalRef totalCand: totalCand [

	| ngramRec factor |
	ngramRec := Dictionary new.
	factor := beta squared. 

	matching keysAndValuesDo: [ :order :matchCount |
			| rec |
			
			rec := (totalRef at: order ifAbsent: [ 0 ]) > 0
				       ifTrue: [ matchCount / (totalRef at: order) ].
				
			ngramRec at: order put: rec ].

	^ ngramRec
]

{ #category : 'unused' }
LLMChRF >> collectDocumentLevelCharCandCountWith: bestChrCandCount [
    | totalChrCandCount |
    totalChrCandCount := Dictionary new.
    1 to: maxCharOrder do: [:order |
        totalChrCandCount
            at: order
            put: (totalChrCandCount at: order ifAbsent: [ 0 ])
                + (bestChrCandCount at: order ifAbsent: [ 0 ]).
    ].
    ^ totalChrCandCount

]

{ #category : 'unused' }
LLMChRF >> collectDocumentLevelCharMatchingCountWith: bestChrMatchingCount [
    | totalChrMatchingCount |
    totalChrMatchingCount := Dictionary new.
    1 to: maxCharOrder do: [:order |
        totalChrMatchingCount
            at: order
            put: (totalChrMatchingCount at: order ifAbsent: [ 0 ])
                + (bestChrMatchingCount at: order ifAbsent: [ 0 ]).
    ].
    ^ totalChrMatchingCount

]

{ #category : 'unused' }
LLMChRF >> collectDocumentLevelCharRefCountWith: bestChrRefCount [
    | totalChrRefCount |
    totalChrRefCount := Dictionary new.
    1 to: maxCharOrder do: [:order |
        totalChrRefCount
            at: order
            put: (totalChrRefCount at: order ifAbsent: [ 0 ])
                + (bestChrRefCount at: order ifAbsent: [ 0 ]).
    ].
    ^ totalChrRefCount

]

{ #category : 'unused' }
LLMChRF >> collectDocumentLevelTotalWordCandCountWith: bestWordCandCount [
    | totalWordCandCount |
    totalWordCandCount := Dictionary new.
    1 to: maxWordOrder do: [:order |
        totalWordCandCount
            at: order
            put: (totalWordCandCount at: order ifAbsent: [ 0 ])
                + (bestWordCandCount at: order ifAbsent: [ 0 ]).
    ].
    ^ totalWordCandCount

]

{ #category : 'unused' }
LLMChRF >> collectDocumentLevelTotalWordMatchingCountWith: bestWordMatchingCount [
    | totalWordMatchingCount |
    totalWordMatchingCount := Dictionary new.
    1 to: maxWordOrder do: [:order |
        totalWordMatchingCount
            at: order
            put: (totalWordMatchingCount at: order ifAbsent: [ 0 ])
                + (bestWordMatchingCount at: order ifAbsent: [ 0 ]).
    ].
    ^ totalWordMatchingCount

]

{ #category : 'unused' }
LLMChRF >> collectDocumentLevelTotalWordRefCountWith: bestWordRefCount [
    | totalWordRefCount |
    totalWordRefCount := Dictionary new.
    1 to: maxWordOrder do: [:order |
        totalWordRefCount
            at: order
            put: (totalWordRefCount at: order ifAbsent: [ 0 ])
                + (bestWordRefCount at: order ifAbsent: [ 0 ]).
    ].
    ^ totalWordRefCount

]

{ #category : 'as yet unclassified' }
LLMChRF >> computeFinalScoresFrom: docStats [

"docStats contains the best ngram values.

It will be used to find Fscore, precision and Recall in the order of Ngram order.

finally all the scores will be used to calculate the overall chrf score

"
    | wordF wordP wordR chrF chrP chrR totalF totalP totalR |

    wordF := self calculateNgramFscore: (docStats at: #wordMatching)
                    totalRef: (docStats at: #wordRef)
                    totalCand: (docStats at: #wordCand).
    wordP := self calculateNgramPrecision: (docStats at: #wordMatching)
                    totalRef: (docStats at: #wordRef)
                    totalCand: (docStats at: #wordCand).
    wordR := self calculateNgramRecall: (docStats at: #wordMatching)
                    totalRef: (docStats at: #wordRef)
                    totalCand: (docStats at: #wordCand).

    chrF := self calculateNgramFscore: (docStats at: #chrMatching)
                   totalRef: (docStats at: #chrRef)
                   totalCand: (docStats at: #chrCand).
    chrP := self calculateNgramPrecision: (docStats at: #chrMatching)
                   totalRef: (docStats at: #chrRef)
                   totalCand: (docStats at: #chrCand).
    chrR := self calculateNgramRecall: (docStats at: #chrMatching)
                   totalRef: (docStats at: #chrRef)
                   totalCand: (docStats at: #chrCand).

    totalF := (wordF values sum + chrF values sum) / (maxWordOrder + maxCharOrder).
    totalP := (wordP values sum + chrP values sum) / (maxWordOrder + maxCharOrder).
    totalR := (wordR values sum + chrR values sum) / (maxWordOrder + maxCharOrder).

    ^ Dictionary new
        at: #totalFScore put: totalF;
        at: #totalPrecision put: totalP;
        at: #totalRecall put: totalR;
        at: #wordFScores put: wordF;
        at: #charFScores put: chrF;
        yourself
]

{ #category : 'as yet unclassified' }
LLMChRF >> findBestReferenceMatchForCandidate: candidate againstReferences: references [

	| wordNgramCount_candidate charNgramCount_candidate bestScore bestMatch |
	wordNgramCount_candidate := self getWordNgramCounts: candidate.
	charNgramCount_candidate := self getCharacterNgramCounts: candidate.

	bestScore := Float infinity negated. 
	bestMatch := nil.

	references do: [ :reference |
			| match |
			match := self
				         scoreCandidate: candidate
				         wordNgrams: wordNgramCount_candidate
				         charNgrams: charNgramCount_candidate
				         againstReference: reference.

			(match at: #sentF) > bestScore ifTrue: [
					bestScore := match at: #sentF.
					bestMatch := match ] ].

	^ bestMatch
]

{ #category : 'character-level' }
LLMChRF >> getCharacterNgramCounts: aString [
	"{
    1: {'t':2, 'r':1, 'a':2, 'n':2, 's':1, 'l':1, 'i':1, 'o':1},
    2: {'tr':1, 'ra':1, 'an':1, 'ns':1, 'sl':1, 'la':1, 'at':1, 'ti':1, 'io':1, 'on':1}
}"

	| cleanString result |
	cleanString := aString copyWithoutAll: ' '.
	result := Dictionary new.
	1 to: maxCharOrder do: [ :n |
			| counts |
			counts := Dictionary new.
			1 to: cleanString size - n + 1 do: [ :i |
					| ngram |
					ngram := cleanString copyFrom: i to: i + n - 1.
					counts
						at: ngram
						ifPresent: [ :num | counts at: ngram put: num + 1 ]
						ifAbsent: [ counts at: ngram put: 1 ] ].
			result at: n put: counts ].
	
	^ result
]

{ #category : 'word-level' }
LLMChRF >> getWordNgramCounts: aString [
	"{
    1: {'t':2, 'r':1, 'a':2, 'n':2, 's':1, 'l':1, 'i':1, 'o':1},
    2: {'tr':1, 'ra':1, 'an':1, 'ns':1, 'sl':1, 'la':1, 'at':1, 'ti':1, 'io':1, 'on':1}
}"

	| tokens finalDict |
	tokens := aString splitOn: Character space.
	finalDict := Dictionary new.

	1 to: maxWordOrder do: [ :n |
		finalDict at: n put: (self ngramsOfOrder: n fromTokens: tokens) ].
	^ finalDict
]

{ #category : 'as yet unclassified' }
LLMChRF >> initDatasetWith: listOfcandidates and: listOfreferences [
	self candidateSets: OrderedCollection new.
	listOfcandidates
		with: listOfreferences
		collect: [ :candidate :references |
				| llmCandidateSet |
				llmCandidateSet := LLMCandiateSet new.

				llmCandidateSet candidateSourcecode: candidate.
				llmCandidateSet referencesSourcecode: references.

				self candidateSets add: llmCandidateSet.]
]

{ #category : 'initialization' }
LLMChRF >> initialize [

	super initialize.
	maxWordOrder := 4.
	maxCharOrder := 4
]

{ #category : 'initialization' }
LLMChRF >> initializeDocumentStats [
"To accumulate the best ngram values(matching, candidate and ref) to finally calculate overal score."
	^ Dictionary new
		  at: #wordMatching put: Dictionary new;
		  at: #wordRef put: Dictionary new;
		  at: #wordCand put: Dictionary new;
		  at: #chrMatching put: Dictionary new;
		  at: #chrRef put: Dictionary new;
		  at: #chrCand put: Dictionary new;
		  yourself
]

{ #category : 'as yet unclassified' }
LLMChRF >> matchCountsForCandidate: candidate ref: reference [
"dictionary with {order:matchcount } {1:3 2:1 3:0 4:0 }"
"Can be used with wordNgrams as well as Charater Ngrams- two kinds of tests provided"
	| matching |
	matching := Dictionary new.

	reference keysAndValuesDo: [ :order :refBag |
			| candBag matchCount |
			candBag := candidate at: order ifAbsent: [ Dictionary new ].
			matchCount := 0.

			refBag keysAndValuesDo: [ :ngram :refCount |
					(candBag keys includes: ngram) ifTrue: [
							matchCount := matchCount + (refCount min: (candBag at: ngram)) 
					]
			].

			matching at: order put: matchCount ].

	^ matching
]

{ #category : 'accessing' }
LLMChRF >> maxCharOrder [

	^ maxCharOrder
]

{ #category : 'accessing' }
LLMChRF >> maxCharOrder: anObject [

	maxCharOrder := anObject
]

{ #category : 'accessing' }
LLMChRF >> maxWordOrder [

	^ maxWordOrder
]

{ #category : 'accessing' }
LLMChRF >> maxWordOrder: anObject [

	maxWordOrder := anObject
]

{ #category : 'as yet unclassified' }
LLMChRF >> ngramsOfOrder: n fromTokens: tokens [

	| counts |
	counts := Dictionary new.
    1 to: (tokens size - n + 1) do: [:i |
        | ngramStr |
        ngramStr := (tokens copyFrom: i to: i + n - 1) joinUsing: ' '.
        counts at: ngramStr
            ifPresent: [:count | counts at: ngramStr put: count + 1]
            ifAbsent: [counts at: ngramStr put: 1].
    ].
    ^ counts
]

{ #category : 'as yet unclassified' }
LLMChRF >> scoreCandidate: candidate wordNgrams: wordNgramCount_candidate charNgrams: charNgramCount_candidate againstReference: reference [

	| wordNgramCount_reference charNgramCount_reference matchingWord totalWordRef totalWordCand matchingChr totalChrRef totalChrCand wordF wordP wordR chrF chrP chrR sentF |
	wordNgramCount_reference := self getWordNgramCounts: reference.
	charNgramCount_reference := self getCharacterNgramCounts: reference.

	matchingWord := self
		                matchCountsForCandidate: wordNgramCount_candidate
		                ref: wordNgramCount_reference.
	totalWordRef := self
		                totalRefNgramCount: wordNgramCount_candidate
		                ref: wordNgramCount_reference.
	totalWordCand := self
		                 totalCandNgramCount: wordNgramCount_candidate
		                 ref: wordNgramCount_reference.

	matchingChr := self
		               matchCountsForCandidate: charNgramCount_candidate
		               ref: charNgramCount_reference.
	totalChrRef := self
		               totalRefNgramCount: charNgramCount_candidate
		               ref: charNgramCount_reference. "⚠️ Note: method name may be misleading"
	totalChrCand := self
		                totalCandNgramCount: charNgramCount_candidate
		                ref: charNgramCount_reference.

	wordF := self
		         calculateNgramFscore: matchingWord
		         totalRef: totalWordRef
		         totalCand: totalWordCand.
	wordP := self
		         calculateNgramPrecision: matchingWord
		         totalRef: totalWordRef
		         totalCand: totalWordCand.
	wordR := self
		         calculateNgramRecall: matchingWord
		         totalRef: totalWordRef
		         totalCand: totalWordCand.

	chrF := self
		        calculateNgramFscore: matchingChr
		        totalRef: totalChrRef
		        totalCand: totalChrCand.
	chrP := self
		        calculateNgramPrecision: matchingChr
		        totalRef: totalChrRef
		        totalCand: totalChrCand.
	chrR := self
		        calculateNgramRecall: matchingChr
		        totalRef: totalChrRef
		        totalCand: totalChrCand.

	sentF := wordF values sum + chrF values sum
	         / (maxWordOrder + maxCharOrder).

	^ Dictionary new
		  at: #sentF put: sentF;
		  at: #wordMatching put: matchingWord;
		  at: #wordRef put: totalWordRef;
		  at: #wordCand put: totalWordCand;
		  at: #chrMatching put: matchingChr;
		  at: #chrRef put: totalChrRef;
		  at: #chrCand put: totalChrCand;
		  yourself
]

{ #category : 'calculating' }
LLMChRF >> totalCandNgramCount: candidate ref: reference [
"Can be used with wordNgrams as well as Charater Ngrams- two kinds of tests provided"
	| totalCand |
	totalCand := Dictionary new.


	reference keysAndValuesDo: [ :order :refBag |
			| candBag candTotal |
			candBag := candidate at: order ifAbsent: [ Dictionary new ].
			candTotal := 0.
			candBag valuesDo: [ :count | candTotal := candTotal + count ].
			totalCand at: order put: candTotal ].

	^ totalCand
]

{ #category : 'unused' }
LLMChRF >> totalCountsFor: ngramsPerOrder [
	^ ngramsPerOrder collect: [ :ngrams | ngrams size ]
]

{ #category : 'calculating' }
LLMChRF >> totalRefNgramCount: candidate ref: reference [
"Can be used with wordNgrams as well as Charater Ngrams- two kinds of tests provided"
	| totalRef |
	totalRef := Dictionary new.

	reference keysAndValuesDo: [ :order :refBag |
			| refTotal |
			refTotal := 0.
			refBag valuesDo: [ :count | refTotal := refTotal + count ].
			totalRef at: order put: refTotal ].

	^ totalRef
]
