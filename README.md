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


