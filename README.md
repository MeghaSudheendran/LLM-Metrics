# LLM-Metrics
Implementation of some metrics on LLM in Pharo


# Metric 1
## LLMChRF — Character F-score (chrF) Metric Implementation in Pharo

This repository provides an implementation of the chrF metric — a character n-gram F-score commonly used to evaluate machine translation and text generation quality.

The implementation is designed to work with code or text datasets, supporting both word-level and character-level n-gram precision/recall and final F-score calculation.

## What is chrF?

chrF is an automatic evaluation metric that:

Computes n-gram overlap between a candidate and reference(s).

Works at character and word level.

Produces an F-score that balances precision and recall using a configurable β (beta) parameter.

## Key facts

Type: Automatic evaluation metric

[Read the paper on ResearchGate](https://www.researchgate.net/publication/281677746_chrF_character_n-gram_F-score_for_automatic_MT_evaluation)

Introduced: 2015 by Maja Popović

Basis: Character n-grams and F-score formulation

Primary use: Machine translation quality evaluation

Variants: chrF1, chrF2 (weighted recall emphasis)

## Usage Example
```
listOfcandidates := OrderedCollection with:
	                    '! [ooo].not-used: integer :: libeta
                        integer :: iur
                        integer :: iur2
                        character(len=200) :: name1
                        character(len=200) :: name2
                        type(user), pointer :: ur
                        type(tlib), pointer :: lb'.
listOfreferences := OrderedCollection with: (OrderedCollection with:
		                    
                      '!  local variables    
                          ! [ooo].not-used: integer :: libeta
                      
                          integer :: iur
                          integer :: iur2
                          character(len=200) :: name1
                          character(len=200) :: name2
                      
                          type(user), pointer :: ur
                          type(tlib), pointer :: lb
                      ').
chrf := LLMChRF new.
chrf initDatasetWith: listOfcandidates and: listOfreferences.
chrfFScore := chrf calculateChRF.
chrfFScore asFloat * 100
```

## Testing & Evaluation

This implementation was tested using the [WMT12 translation task](https://www.statmt.org/wmt12/translation-task.html) dataset and evaluation setting (as referenced in Popović’s paper).


# ChRF Score API Documentation

A REST API service for calculating ChRF (Character n-gram F-score) metrics for machine translation evaluation.

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Starting the Server](#starting-the-server)
- [API Endpoints](#api-endpoints)
- [Usage Examples](#usage-examples)
- [CSV Batch Processing](#csv-batch-processing)

## Overview

ChRF is a character-level evaluation metric for machine translation that correlates well with human judgments. This API provides a simple HTTP interface to calculate ChRF scores between candidate translations and reference translations.

**Features:**
- RESTful API for ChRF score calculation
- Built-in CSV batch processing
- Written in Pharo Smalltalk using Zinc HTTP Components

## Installation

### Prerequisites
- Pharo 11+ (recommended: Pharo 13)
- Zinc HTTP Components (included in Pharo)
- NeoCSV (for CSV processing)
- STON (for JSON handling)

### Setup

1. Load the required packages (if not already present):
```smalltalk
Metacello new
  baseline: 'NeoCSV';
  repository: 'github://svenvc/NeoCSV/repository';
  load.
```


## Starting the Server

### Basic Server Start

```smalltalk
"Start server on port 8080"
server := CHRFServer new startCHRFServiceOn: 8080.
```

### Stop Server

```smalltalk
server stop.
```


## API Endpoints

### POST /chrf

Calculate ChRF score between candidates and references.

**Endpoint:** `POST http://localhost:8080/chrf`

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "candidates": [
    "candidate translation text 1",
    "candidate translation text 2"
  ],
  "references": [
    ["reference translation 1 for candidate 1"],
    ["reference translation 1 for candidate 2", "reference translation 2 for candidate 2"]
  ]
}
```

**Response:**
```json
{
  "chrf_score": 85.42,
  "status": "success"
}
```

**Notes:**
- `candidates`: Array of candidate translations (strings)
- `references`: Array of arrays - each element is an array of reference translations for the corresponding candidate
- `chrf_score`: Float value between 0-100 (higher is better)



## Usage Examples

### cURL

#### Single Candidate with Single Reference

```bash
curl -X POST http://localhost:8080/chrf \
  -H "Content-Type: application/json" \
  -d '{
    "candidates": ["The cat sits on the mat"],
    "references": [["The cat is sitting on the mat"]]
  }'
```

#### Single Candidate with Multiple References

```bash
curl -X POST http://localhost:8080/chrf \
  -H "Content-Type: application/json" \
  -d '{
    "candidates": ["The cat sits on the mat"],
    "references": [
      [
        "The cat is sitting on the mat",
        "A cat sits on a mat",
        "The feline is on the mat"
      ]
    ]
  }'
```

#### Code Translation Example

```bash
curl -X POST http://localhost:8080/chrf \
  -H "Content-Type: application/json" \
  -d '{
    "candidates": [
      "! local variables\ninteger :: iur\ncharacter(len=200) :: name1"
    ],
    "references": [
      [
        "!  local variables\n    integer :: iur\n    character(len=200) :: name1"
      ]
    ]
  }'
```

### Pharo Smalltalk

#### Simple Request

```smalltalk
| payload response result |
payload := {
    (#candidates -> #('The cat sits on the mat')).
    (#references -> #(#('The cat is sitting on the mat')))
} asDictionary.

response := ZnClient new
    url: 'http://localhost:8080/chrf';
    entity: (ZnEntity json: (STONJSON toString: payload));
    post.

result := STONJSON fromString: response.
result at: #chrf_score.  "Returns the score"
```

## CSV Batch Processing

The API includes built-in support for processing CSV files with translation candidates and references.

### CSV Format

Your CSV should have the following columns:

```csv
id,legacy_code,reference_code,mistral_translated_code,mistral_translated_score,qwen_translated_code,qwen_translated_score
1,original_code1,reference1,translated1,,translated2,
2,original_code2,reference2,translated3,,translated4,
```

### Process CSV File

```smalltalk
LLMChRFEvaluation new updateCSVFile: '/path/to/data.csv'
```

### How It Works

1. Reads the CSV file
2. For each row:
   - Checks if `mistral_translated_score` is empty
   - If empty, calculates ChRF between `mistral_translated_code` and `reference_code`
   - Does the same for `qwen_translated_score` and `qwen_translated_code`
   - ....More models and its responses can be added.... (Updation required accordingly)
3. Writes the updated CSV with calculated scores


## Configuration

### Custom Port

```smalltalk
"Start on custom port"
server := CHRFServer new startCHRFServiceOn: 9000.
```


## Troubleshooting

### Server not responding
```smalltalk
"Check if server is running"
ZnServer allInstances.

"Restart server"
server stop.
server := CHRFServer new startCHRFServiceOn: 8080.
```

### Port already in use
```smalltalk
"Stop all servers on that port"
runningServer := (ZnServer withAllSubclasses flatCollect:
		                  #allInstances)
		                 detect: [ :s | s port = 8080 and: [ s isRunning ] ]
		                 ifNone: [ nil ].
	runningServer ifNotNil: [ runningServer stop ].
```

### 404 Not Found
- Verify the server is running: `server isRunning`
- Check the route is registered: visit `http://localhost:8080/help`
- Ensure you're using the correct URL and port



