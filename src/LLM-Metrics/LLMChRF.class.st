Class {
	#name : 'LLMChRF',
	#superclass : 'LLMDataSet',
	#instVars : [
		'maxWordOrder',
		'maxCharOrder',
		'beta',
		'candidate_result'
	],
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'as yet unclassified' }
LLMChRF >> calculateChRF [

	| totalWordMatchingCount totalRefCount totalHypCount totalChrMatchingCount totalChrRefCount totalChrHypCount |
	totalWordMatchingCount := Dictionary new.
	totalRefCount := Dictionary new.
	totalHypCount := Dictionary new.
	totalChrMatchingCount := Dictionary new.
	totalChrRefCount := Dictionary new.
	totalChrHypCount := Dictionary new.



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


					" will return wordNgramF, wordNgramRec, wordNgramPrec"

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

					maxF > sentF ifTrue: [ "chrNgramF, chrNgramRec, chrNgramPrec"
							maxF := sentF.
							bestWordMatchingCount := matchingWordNgramCounts.
							bestWordRefCount := totalWordRefNgramCount.
							bestWordCandCount := totalWordCandNgramCount.

							bestChrMatchingCount := matchingChrNgramCounts.
							bestChrRefCount := totalChrRefNgramCount at: 2.
							bestChrCandCount := totalChrCandNgramCount at: 3 ] ].


			"collect document level ngram counts"
			1 to: maxWordOrder do: [ :order |
					totalWordMatchingCount
						at: order
						put: (totalWordMatchingCount at: order ifAbsent: [ 0 ])
							+ (bestWordMatchingCount at: order ifAbsent: [ 0 ]).
					totalRefCount
						at: order
						put: (totalRefCount at: order ifAbsent: [ 0 ])
							+ (bestWordRefCount at: order ifAbsent: [ 0 ]).
					totalHypCount
						at: order
						put: (totalHypCount at: order ifAbsent: [ 0 ])
							+ (bestWordCandCount at: order ifAbsent: [ 0 ]) ].

			1 to: maxCharOrder do: [ :order |
					totalChrMatchingCount
						at: order
						put: (totalChrMatchingCount at: order ifAbsent: [ 0 ])
							+ (bestChrMatchingCount at: order ifAbsent: [ 0 ]).
					totalChrRefCount
						at: order
						put: (totalChrRefCount at: order ifAbsent: [ 0 ])
							+ (bestChrRefCount at: order ifAbsent: [ 0 ]).
					totalChrHypCount
						at: order
						put: (totalChrHypCount at: order ifAbsent: [ 0 ])
							+ (bestChrCandCount at: order ifAbsent: [ 0 ]) ] ]
]

{ #category : 'as yet unclassified' }
LLMChRF >> calculateNgramFscore: matching totalRef: totalRef totalCand: totalCand [

	| ngramF factor |
	ngramF := Dictionary new.
	factor := beta squared. "beta**2"

	matching keysAndValuesDo: [ :order :matchCount |
			| prec rec denom |
			prec := (totalCand at: order ifAbsent: [ 0 ]) > 0
				        ifTrue: [ matchCount / (totalCand at: order) ]
				        ifFalse: [ 1e-16 ].

			rec := (totalRef at: order ifAbsent: [ 0 ]) > 0
				       ifTrue: [ matchCount / (totalRef at: order) ]
				       ifFalse: [ 1e-16 ].

			denom := factor * prec + rec.

			ngramF at: order put: (denom > 0
					 ifTrue: [ 1 + factor * prec * rec / denom ]
					 ifFalse: [ 1e-16 ]) ].

	^ ngramF
]

{ #category : 'as yet unclassified' }
LLMChRF >> calculateNgramPrecision: matching totalRef: totalRef totalCand: totalCand [

	| ngramPrec factor |
	ngramPrec := Dictionary new.
	factor := beta squared. "beta**2"

	matching keysAndValuesDo: [ :order :matchCount |
			| prec rec denom |
			prec := (totalCand at: order ifAbsent: [ 0 ]) > 0
				        ifTrue: [ matchCount / (totalCand at: order) ]
				        ifFalse: [ 1e-16 ].

			rec := (totalRef at: order ifAbsent: [ 0 ]) > 0
				       ifTrue: [ matchCount / (totalRef at: order) ]
				       ifFalse: [ 1e-16 ].

			denom := factor * prec + rec.

			ngramPrec at: order put: prec ].

	^ ngramPrec
]

{ #category : 'as yet unclassified' }
LLMChRF >> calculateNgramRecall: matching totalRef: totalRef totalCand: totalCand [

	| ngramRec factor |
	ngramRec := Dictionary new.
	factor := beta squared. "beta**2"

	matching keysAndValuesDo: [ :order :matchCount |
			| prec rec denom |
			prec := (totalCand at: order ifAbsent: [ 0 ]) > 0
				        ifTrue: [ matchCount / (totalCand at: order) ]
				        ifFalse: [ 1e-16 ].

			rec := (totalRef at: order ifAbsent: [ 0 ]) > 0
				       ifTrue: [ matchCount / (totalRef at: order) ]
				       ifFalse: [ 1e-16 ].

			denom := factor * prec + rec.

			ngramRec at: order put: rec ].

	^ ngramRec
]

{ #category : 'as yet unclassified' }
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

{ #category : 'as yet unclassified' }
LLMChRF >> getMatchingCharacterNgramCount: charNgramCountCandidate referenceNgramCount: charNgramCountReference [

	
]

{ #category : 'as yet unclassified' }
LLMChRF >> getMatchingWordNgramCount: wordNgramCountCandidate referenceNgramCount: wordNgramCountReference [
]

{ #category : 'as yet unclassified' }
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

{ #category : 'accessing' }
LLMChRF >> totalCountsFor: ngramsPerOrder [
	^ ngramsPerOrder collect: [ :ngrams | ngrams size ]
]

{ #category : 'as yet unclassified' }
LLMChRF >> totalWordCandNgramCount: candidate ref: reference [
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

{ #category : 'as yet unclassified' }
LLMChRF >> totalWordRefNgramCount: candidate ref: reference [
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
