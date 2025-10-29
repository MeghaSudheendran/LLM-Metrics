Class {
	#name : 'CHRFServer',
	#superclass : 'Object',
	#instVars : [
		'server'
	],
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'request_handling' }
CHRFServer >> getScore: candidates listOfreferences: references [

	| listOfcandidates listOfreferences chrf |
	listOfcandidates := OrderedCollection withAll: candidates.
	listOfreferences := OrderedCollection new.
	listOfreferences addAll: (references collect: [ :refList |
				 refList isCollection
					 ifTrue: [ refList asOrderedCollection ]
					 ifFalse: [ OrderedCollection with: refList ] ]).
	chrf := LLMChRF new.
	chrf initDatasetWith: listOfcandidates and: listOfreferences.
	^ chrf calculateChRF asFloat * 100
]

{ #category : 'services' }
CHRFServer >> handleChRFRequest: request [

	| json candidates references score |
	
	request method = #POST ifFalse: [
		^ ZnResponse badRequest: 'Only POST allowed' ].

	json := STONJSON fromString: request entity contents.

	candidates := json
		              at: 'candidates'
		              ifAbsent: [
		              ^ ZnResponse badRequest: 'missing candidates' ].

	references := json
		              at: 'references'
		              ifAbsent: [
		              ^ ZnResponse badRequest: 'missing references' ].

	score := self getScore: candidates listOfreferences: references.


	^ ZnResponse ok: (ZnEntity json: (STONJSON toString: {
					    (#chrf_score -> score).
					    (#status -> 'success') } asDictionary))
]

{ #category : 'services' }
CHRFServer >> startCHRFServiceOn: port [

	server := ZnServer startOn: port.
	server delegate
		map: 'chrf'
		to: [ :request | self handleChRFRequest: request ]
]

{ #category : 'services' }
CHRFServer >> stop [

	| runningServer |
	runningServer := (ZnServer withAllSubclasses flatCollect:
		                  #allInstances)
		                 detect: [ :s | s port = 8080 and: [ s isRunning ] ]
		                 ifNone: [ nil ].
	runningServer ifNotNil: [ runningServer stop ]
]
