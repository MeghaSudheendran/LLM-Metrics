Class {
	#name : 'LLMChRFEvaluation',
	#superclass : 'Object',
	#category : 'LLM-Metrics',
	#package : 'LLM-Metrics'
}

{ #category : 'as yet unclassified' }
LLMChRFEvaluation >> calculateMissingScoresFor: data withModelColumns: modelColumns [
	"Calculate scores for all model columns dynamically"
	| reference |
	reference := data at: #Reference.
	
	modelColumns do: [ :modelCol |
		| outputName scoreName candidate |
		outputName := (modelCol at: #outputName) asSymbol.
		scoreName := (modelCol at: #scoreName) asSymbol.
		candidate := data at: outputName.
		
		self
			calculateScoreFor: scoreName
			candidate: candidate
			reference: reference
			in: data
	]
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
"Calculate score if missing. Leave empty if inputs are empty."
	| currentScore |
	
	currentScore := data at: scoreKey.
	
	"Only proceed if score needs calculation"
	(currentScore isNil or: [ #( '' '-1.0' ) includes: currentScore ]) 
		ifFalse: [ ^ self ].
	
	"Skip calculation if inputs are empty, leave score empty"
	(candidate isNil or: [ candidate isEmpty ]) ifTrue: [ ^ self ].
	(reference isNil or: [ reference isEmpty ]) ifTrue: [ ^ self ].
	
	"Calculate score"
	[
		data
			at: scoreKey
			put: (self calculateScore: candidate reference: reference) asString
	] on: Error do: [ :ex | 
		data at: scoreKey put: 'ERROR'.
		Transcript show: 'Error for ', scoreKey asString, ': ', ex messageText; cr
	]
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> extractDataFrom: row withHeaders: headers [
	"Extract data from row into a dictionary using headers"
	| data |
	data := Dictionary new.
	headers withIndexDo: [ :header :index |
		data at: header asSymbol put: (row at: index ifAbsent: [ '' ])
	].
	^ data
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> getModelColumnsFrom: headers [
	"Extract model output and score column pairs from headers.
	Returns a collection of dictionaries with outputCol and scoreCol keys"
	| modelColumns |
	modelColumns := OrderedCollection new.
	
	headers withIndexDo: [ :header :index |
		(header beginsWith: 'output_') ifTrue: [
			(header endsWith: 'score') ifFalse: [
				| scoreColName scoreIndex |
				scoreColName := header , '_score'.
				scoreIndex := headers indexOf: scoreColName.
				scoreIndex = 0 ifTrue: [
					scoreColName := header , '_Score'.
					scoreIndex := headers indexOf: scoreColName
				].
				modelColumns add: {
					#outputCol -> index.
					#scoreCol -> scoreIndex.
					#outputName -> header.
					#scoreName -> scoreColName
				} asDictionary
			]
		]
	].
	^ modelColumns
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> processCSVFile: inputFilePath outputFilePath: outputFilePath [
	"Read CSV, calculate ChRF scores, and write results."

	"| rows outputRows |
	rows := self readCSVFrom: inputFilePath.
	outputRows := self processRows: rows.
	self writeCSV: outputRows toFile: outputFilePath.

	^ outputRows size"

	"Main method to process entire CSV file"

	"Main method to process entire CSV file"

	"Main method to process entire CSV file"
	| headers rows modelColumns inputStream |
	
	"Read headers"
	headers := self readHeaders: inputFilePath.
	
	"Get model columns once"
	modelColumns := self getModelColumnsFrom: headers.
	
	"Process all rows"
	rows := OrderedCollection new.
	rows add: headers. "Add header row first"
	
	inputStream := inputFilePath asFileReference readStream.
	[
		(NeoCSVReader on: inputStream)
			separator: $;;
			skipHeader;
			do: [ :row | 
				| processedRow |
				processedRow := self 
					processRow: row 
					withHeaders: headers 
					modelColumns: modelColumns.
				rows add: processedRow
			]
	] ensure: [ inputStream close ].
	
	"Write output"
	self writeCSV: rows toFile: outputFilePath
]

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> processRow: row withHeaders: headers modelColumns: modelColumns [
	"Process a single row and calculate missing scores dynamically"
	| data |
	data := self extractDataFrom: row withHeaders: headers.
	self calculateMissingScoresFor: data withModelColumns: modelColumns.
	
	"Return row data in header order"
	^ headers collect: [ :header | 
		data at: header asSymbol ifAbsent: [ '' ]
	]
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

{ #category : 'evaluation_csv' }
LLMChRFEvaluation >> readHeaders: filePath [
	"Read and return CSV headers"

	| input headers |
	input := filePath asFileReference readStream.
	headers := [
		           (NeoCSVReader on: input)
			           separator: $;;
			           readHeader ] ensure: [ input close ].
	^ headers
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

{ #category : 'as yet unclassified' }
LLMChRFEvaluation >> sendFileFromRemote: remoteFile fileDestination: localDestination [
	"Metacello new
    baseline: 'OSSubprocess';
    repository: 'github://pharo-contributions/OSSubprocess:master/repository';
    load.
"

	"resultFile := 'msudheen@access.grid5000.fr:lille/MyFortranTranslator/example.env'.
resultDestination := '/Users/meghasudheendran/Documents/LLMExperimentData/22_dec_2025/'.
"

	OSSUnixSubprocess new
		command: '/usr/bin/scp';
		arguments: {
				remoteFile.
				localDestination };
		redirectStderr;
		runAndWaitOnExitDo: [ :process :outString |
				process isSuccess
					ifTrue: [ UIManager default inform: 'Upload Successful!' ]
					ifFalse: [ process stderrStream contents inspect ] ]
]

{ #category : 'as yet unclassified' }
LLMChRFEvaluation >> sendFileToRemote: localFile fileDestination: remoteTarget [
"Metacello new
    baseline: 'OSSubprocess';
    repository: 'github://pharo-contributions/OSSubprocess:master/repository';
    load.
"

"localFile := '/Users/meghasudheendran/Documents/LLMExperimentData/22_dec_2025/input.csv'.
remoteTarget := 'msudheen@access.grid5000.fr:lille/MyFortranTranslator/'."

	OSSUnixSubprocess new
		command: '/usr/bin/scp';
		arguments: {
				localFile.
				remoteTarget };
		redirectStderr;
		runAndWaitOnExitDo: [ :process :outString |
				process isSuccess
					ifTrue: [ UIManager default inform: 'Upload Successful!' ]
					ifFalse: [ process stderrStream contents inspect ] ]
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
			nextPutAll: rows ] ensure: [ output close ]

	"Write rows to CSV file with header"
	"
	| output |
	output := filePath asFileReference writeStream.
	[
		(NeoCSVWriter on: output)
			separator: $;;
			nextPut:
				#( 'id' 'legacy_code' 'Reference' 'output_codellama_CodeLlama_7b_Instruct_hf'
				   'output_codellama_CodeLlama_7b_Instruct_hf_Score'
				   'output_codellama_CodeLlama_13b_Instruct_hf'
				   'output_codellama_CodeLlama_13b_Instruct_hf_score'
				   'output_mistralai_Mistral_7B_Instruct_v0_3'
				   'output_mistralai_Mistral_7B_Instruct_v0_3_score'
				   'output_Qwen_Qwen2_7B_Instruct' 'output_Qwen_Qwen2_7B_Instruct_score'
				   'output_Qwen_Qwen2_5_Coder_3B' 'output_Qwen_Qwen2_5_Coder_3B_score'
				   'output_Qwen_Qwen2_5_Coder_7B_Instruct'
				   'output_Qwen_Qwen2_5_Coder_7B_Instruct_score'
				   'output_Qwen_Qwen2_5_Coder_7B' 'output_Qwen_Qwen2_5_Coder_7B_score'
				   'output_Qwen_Qwen2_5_Coder_14B_Instruct'
				   'output_Qwen_Qwen2_5_Coder_14B_Instruct_score'
				   'output_Qwen_Qwen2_5_Coder_14B' 'output_Qwen_Qwen2_5_Coder_14B_score'
				   'output_Qwen_Qwen3_Coder_30B_A3B_Instruct'
				   'output_Qwen_Qwen3_Coder_30B_A3B_Instruct_score'
				   'output_Qwen_Qwen2_5_Coder_32B_Instruct'
				   'output_Qwen_Qwen2_5_Coder_32B_Instruct_score'
					'output_Qwen_Qwen2_5_Coder_32B'
					'output_Qwen_Qwen2_5_Coder_32B_score'
				 );
			nextPutAll: rows ] ensure: [ output close ]"
]
