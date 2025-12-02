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
		calculateScoreFor: #output_codellama_CodeLlama_7b_Instruct_hf_Score
		candidate: (data at: #output_codellama_CodeLlama_7b_Instruct_hf)
		reference: (data at: #Reference)
		in: data.

	self
		calculateScoreFor: #output_codellama_CodeLlama_13b_Instruct_hf_score
		candidate: (data at: #output_codellama_CodeLlama_13b_Instruct_hf)
		reference: (data at: #Reference)
		in: data.
	self
		calculateScoreFor: #output_mistralai_Mistral_7B_Instruct_v0_3_score
		candidate: (data at: #output_mistralai_Mistral_7B_Instruct_v0_3)
		reference: (data at: #Reference)
		in: data.
	self
		calculateScoreFor: #output_Qwen_Qwen2_7B_Instruct_score
		candidate: (data at: #output_Qwen_Qwen2_7B_Instruct)
		reference: (data at: #Reference)
		in: data.
	self
		calculateScoreFor: #output_Qwen_Qwen2_5_Coder_3B_score
		candidate: (data at: #output_Qwen_Qwen2_5_Coder_3B)
		reference: (data at: #Reference)
		in: data.
	self
		calculateScoreFor: #output_Qwen_Qwen2_5_Coder_7B_Instruct_score
		candidate: (data at: #output_Qwen_Qwen2_5_Coder_7B_Instruct)
		reference: (data at: #Reference)
		in: data.
	self
		calculateScoreFor: #output_Qwen_Qwen2_5_Coder_7B_score
		candidate: (data at: #output_Qwen_Qwen2_5_Coder_7B)
		reference: (data at: #Reference)
		in: data.
	self
		calculateScoreFor: #output_Qwen_Qwen2_5_Coder_14B_Instruct_score
		candidate: (data at: #output_Qwen_Qwen2_5_Coder_14B_Instruct)
		reference: (data at: #Reference)
		in: data.
	self
		calculateScoreFor: #output_Qwen_Qwen2_5_Coder_14B_score
		candidate: (data at: #output_Qwen_Qwen2_5_Coder_14B)
		reference: (data at: #Reference)
		in: data
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> calculateScore: candidate reference: reference [
	"Calculate ChRF score via HTTP service."

	| client response result |
	(candidate isNil or: [ candidate isEmpty ]) ifTrue: [ ^ 0.0 ].
	(reference isNil or: [ reference isEmpty ]) ifTrue: [ ^ 0.0 ].

	client := ZnClient new
		          url: 'http://localhost:8080/chrf';
		          entity: (ZnEntity json: (STONJSON toString: {
								            (#candidates -> { candidate }).
								            (#references -> { { reference } }) } asDictionary));
		          yourself.

	response := client post.

	[ result := STONJSON fromString: response ]
		on: Error
		do: [ ^ -1.0 ].

	^ result at: #chrf_score ifAbsent: [ -1.0 ]
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> calculateScoreFor: scoreKey candidate: candidate reference: reference in: data [
	"Calculate score if missing. "

	| currentScore |
	currentScore := data at: scoreKey.

	(candidate notEmpty and: [
		 currentScore isNil or: [ #( '' '-1.0' ) includes: currentScore ] ])
		ifTrue: [
				[
					data
						at: scoreKey
						put:
						(self calculateScore: candidate reference: reference) asString ]
					on: Error
					do: [ :ex | data at: scoreKey put: 'ERROR' ] ]
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> extractDataFrom: row [
	"Extract data from row into a dictionary."

	^ {
		  (#id -> (row at: 1 ifAbsent: [ '' ])).
		  (#legacyCode -> (row at: 2 ifAbsent: [ '' ])).
		  (#Reference -> (row at: 3 ifAbsent: [ '' ])).
		  (#output_codellama_CodeLlama_7b_Instruct_hf
		   -> (row at: 4 ifAbsent: [ '' ])).
		  (#output_codellama_CodeLlama_7b_Instruct_hf_Score
		   -> (row at: 5 ifAbsent: [ '' ])).
		  (#output_codellama_CodeLlama_13b_Instruct_hf
		   -> (row at: 6 ifAbsent: [ '' ])).
		  (#output_codellama_CodeLlama_13b_Instruct_hf_score
		   -> (row at: 7 ifAbsent: [ '' ])).
		  (#output_mistralai_Mistral_7B_Instruct_v0_3
		   -> (row at: 8 ifAbsent: [ '' ])).
		  (#output_mistralai_Mistral_7B_Instruct_v0_3_score
		   -> (row at: 9 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_7B_Instruct -> (row at: 10 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_7B_Instruct_score
		   -> (row at: 11 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_5_Coder_3B -> (row at: 12 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_5_Coder_3B_score
		   -> (row at: 13 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_5_Coder_7B_Instruct
		   -> (row at: 14 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_5_Coder_7B_Instruct_score
		   -> (row at: 15 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_5_Coder_7B -> (row at: 16 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_5_Coder_7B_score
		   -> (row at: 17 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_5_Coder_14B_Instruct
		   -> (row at: 18 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_5_Coder_14B_Instruct_score
		   -> (row at: 19 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_5_Coder_14B -> (row at: 20 ifAbsent: [ '' ])).
		  (#output_Qwen_Qwen2_5_Coder_14B_score
		   -> (row at: 21 ifAbsent: [ '' ])) } asDictionary
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> processCSVFile: inputFilePath outputFilePath: outputFilePath [
	"Read CSV, calculate ChRF scores, and write results."

	| rows outputRows |
	rows := self readCSVFrom: inputFilePath.
	outputRows := self processRows: rows.
	self writeCSV: outputRows toFile: outputFilePath.

	^ outputRows size
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> processRow: row atIndex: index [
	"Process a single row and calculate missing scores."

	| data |
	data := self extractDataFrom: row.
	self calculateMissingScoresFor: data.

	^ {
		  (data at: #id).
		  (data at: #legacyCode).
		  (data at: #Reference).
		  (data at: #output_codellama_CodeLlama_7b_Instruct_hf).
		  (data at: #output_codellama_CodeLlama_7b_Instruct_hf_Score).
		  (data at: #output_codellama_CodeLlama_13b_Instruct_hf).
		  (data at: #output_codellama_CodeLlama_13b_Instruct_hf_score).
		  (data at: #output_mistralai_Mistral_7B_Instruct_v0_3).
		  (data at: #output_mistralai_Mistral_7B_Instruct_v0_3_score).
		  (data at: #output_Qwen_Qwen2_7B_Instruct).
		  (data at: #output_Qwen_Qwen2_7B_Instruct_score).
		  (data at: #output_Qwen_Qwen2_5_Coder_3B).
		  (data at: #output_Qwen_Qwen2_5_Coder_3B_score).
		  (data at: #output_Qwen_Qwen2_5_Coder_7B_Instruct).
		  (data at: #output_Qwen_Qwen2_5_Coder_7B_Instruct_score).
		  (data at: #output_Qwen_Qwen2_5_Coder_7B).
		  (data at: #output_Qwen_Qwen2_5_Coder_7B_score).
		  (data at: #output_Qwen_Qwen2_5_Coder_14B_Instruct).
		  (data at: #output_Qwen_Qwen2_5_Coder_14B_Instruct_score).
		  (data at: #output_Qwen_Qwen2_5_Coder_14B).
		  (data at: #output_Qwen_Qwen2_5_Coder_14B_score) }
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> processRows: rows [
	"Process each row and calculate missing scores."

	^ rows collectWithIndex: [ :row :index |
		  self processRow: row atIndex: index ]
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> readCSVFrom: filePath [
	"Read CSV file and return rows as arrays."

	| inputCsv |
	inputCsv := filePath asFileReference readStream.
	^ [
		  (NeoCSVReader on: inputCsv)
			  separator: $;;
			  skipHeader;
			  upToEnd ] ensure: [ inputCsv close ]
]

{ #category : 'evaluation' }
LLMChRFEvaluation >> runEvaluationOn: filePath [
	"Read CSV, calculate and update the scores in the same file."

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
	[
		(NeoCSVWriter on: output)
			separator: $;;
			nextPut:
				#( 'id' 
				'legacy_code' 
				'Reference'	
				'output_codellama_CodeLlama_7b_Instruct_hf'	 
				'output_codellama_CodeLlama_7b_Instruct_hf_Score'
				'output_codellama_CodeLlama_13b_Instruct_hf'	
				'output_codellama_CodeLlama_13b_Instruct_hf_score'	
				'output_mistralai_Mistral_7B_Instruct_v0_3' 	
				'output_mistralai_Mistral_7B_Instruct_v0_3_score'	
				'output_Qwen_Qwen2_7B_Instruct'
				'output_Qwen_Qwen2_7B_Instruct_score'
				'output_Qwen_Qwen2_5_Coder_3B'	
				'output_Qwen_Qwen2_5_Coder_3B_score'	
				'output_Qwen_Qwen2_5_Coder_7B_Instruct'	
				'output_Qwen_Qwen2_5_Coder_7B_Instruct_score'	
				'output_Qwen_Qwen2_5_Coder_7B'	
				'output_Qwen_Qwen2_5_Coder_7B_score'	
				'output_Qwen_Qwen2_5_Coder_14B_Instruct'	
				'output_Qwen_Qwen2_5_Coder_14B_Instruct_score'	
				'output_Qwen_Qwen2_5_Coder_14B'	
				'output_Qwen_Qwen2_5_Coder_14B_score');
			nextPutAll: rows ] ensure: [ output close ]
]
