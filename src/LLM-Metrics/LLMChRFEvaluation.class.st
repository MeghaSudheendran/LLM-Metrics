Class {
	#name : 'LLMChRFEvaluation',
	#superclass : 'Object',
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> calculateMissingScoresFor: data [
	"Calculate missing scores for mistral and qwen"
	
	self 
		calculateScoreFor: #mistralScore 
		candidate: (data at: #mistralCode)
		reference: (data at: #referenceCode)
		in: data.
		
	self 
		calculateScoreFor: #qwenScore 
		candidate: (data at: #qwenCode)
		reference: (data at: #referenceCode)
		in: data
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> calculateScore: candidate reference: reference [
	"Calculate ChRF score via HTTP service"
	| client response result |
	
	client := ZnClient new
		url: 'http://localhost:8080/chrf';
		entity: (ZnEntity json: (STONJSON toString: {
			(#candidates -> { candidate }).
			(#references -> { { reference } }) } asDictionary));
		yourself.
		
	response := client post.
	result := STONJSON fromString: response.
	^ result at: #chrf_score
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> calculateScoreFor: scoreKey candidate: candidate reference: reference in: data [
	"Calculate score if missing"
	| currentScore |
	
	currentScore := data at: scoreKey.
	
	(candidate notEmpty and: [ currentScore isNil or: [ currentScore = '' ] ])
		ifTrue: [
			[ data at: scoreKey put: (self calculateScore: candidate reference: reference) asString ]
			on: Error do: [ :ex | data at: scoreKey put: 'ERROR' ] ]

]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> extractDataFrom: row [
	"Extract data from row into a dictionary"
	
	^ {
		(#id -> row first).
		(#legacyCode -> (row at: 2)).
		(#referenceCode -> (row at: 3)).
		(#mistralCode -> (row at: 4)).
		(#mistralScore -> (row at: 5)).
		(#qwenCode -> (row at: 6)).
		(#qwenScore -> (row at: 7)) } asDictionary

]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> processCSVFile: inputFilePath outputFilePath: outputFilePath [
	"Read CSV, calculate ChRF scores, and write results to output CSV"
	| rows outputRows |
	
	rows := self readCSVFrom: inputFilePath.
	outputRows := self processRows: rows.
	self writeCSV: outputRows toFile: outputFilePath.
	
	^ outputRows size
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> processRow: row atIndex: index [
	"Process a single row and calculate missing scores"
	| data |
	
	data := self extractDataFrom: row.
	self calculateMissingScoresFor: data.
	
	^ {
		data at: #id.
		data at: #legacyCode.
		data at: #referenceCode.
		data at: #mistralCode.
		data at: #mistralScore.
		data at: #qwenCode.
		data at: #qwenScore }
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> processRows: rows [
	"Process each row and calculate missing scores"
	
	^ rows collectWithIndex: [ :row :index |
		self processRow: row atIndex: index ]

]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> readCSVFrom: filePath [
	"Read CSV file and return rows as arrays"

	| inputCsv |
	inputCsv := filePath asFileReference readStream.
	^ [
		  (NeoCSVReader on: inputCsv)
			  separator: $,;
			  skipHeader;
			  addField;
			  addField;
			  addField;
			  addField;
			  addField;
			  addField;
			  addField;
			  upToEnd ] ensure: [ inputCsv close ]
]

{ #category : 'evaluation' }
LLMChRFEvaluation >> runEvaluationOn: filePath [
	"Read CSV, calculate and update the scores in the same file"

	| tempFile originalFile |

	originalFile := filePath asFileReference.
	tempFile := originalFile parent / (originalFile basename , '.tmp').

	self processCSVFile: filePath outputFilePath: tempFile fullName.

	originalFile delete.
	tempFile moveTo: originalFile.

	^ 'Updated ' , filePath
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> updateCSVFile: filePath [
	"Update CSV file in-place"
	| tempFile originalFile |
	
	originalFile := filePath asFileReference.
	tempFile := originalFile parent / (originalFile basename, '.tmp').
	
	self processCSVFile: filePath outputFilePath: tempFile fullName.
	
	originalFile delete.
	tempFile moveTo: originalFile.
	
	^ 'Updated ', filePath
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> writeCSV: rows toFile: filePath [
	"Write rows to CSV file with header"
	| output |
	
	output := filePath asFileReference writeStream.
	[ (NeoCSVWriter on: output)
		separator: $,;
		nextPut: #('id' 'legacy_code' 'reference_code' 
			'mistral_translated_code' 'mistral_translated_score' 
			'qwen_translated_code' 'qwen_translated_score');
		nextPutAll: rows ]
	ensure: [ output close ]
]
