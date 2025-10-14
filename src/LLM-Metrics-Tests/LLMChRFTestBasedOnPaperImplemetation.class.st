"
A LLMChRFTest is a test class for testing the behavior of LLMChRF
"
Class {
	#name : 'LLMChRFTestBasedOnPaperImplemetation',
	#superclass : 'TestCase',
	#instVars : [
		'llmChRF'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMChRFTestBasedOnPaperImplemetation >> setUp [
	super setUp.
	llmChRF := LLMChRF new.
	llmChRF maxWordOrder: 2.
	llmChRF maxCharOrder: 6.
	llmChRF beta: 2.
]

{ #category : 'tests' }
LLMChRFTestBasedOnPaperImplemetation >> testCalculateChRF_1 [

	| listOfcandidates listOfreferences chrfFScore |
	listOfcandidates := OrderedCollection with:
		                    'La inflación europea se deslizó en los alimentos'.
	listOfreferences := OrderedCollection with:
		                    (OrderedCollection with:
			                     'Food: Where European inflation slipped up').

	llmChRF initDatasetWith: listOfcandidates and: listOfreferences.

	chrfFScore := llmChRF calculateChRF asFloat * 100.

	"totalF  19.6467"
	self assert: chrfFScore closeTo: 18.4971 precision: 4
]

{ #category : 'tests' }
LLMChRFTestBasedOnPaperImplemetation >> testCalculateChRF_2 [

	| listOfcandidates listOfreferences chrfFScore |
	listOfcandidates := OrderedCollection with:
		                    'La inflación acelerada, registrada en la zona de euro, se debe en primer lugar al vertiginoso crecimiento del precio de los productos alimenticios.'.
	listOfreferences := OrderedCollection with: (OrderedCollection with:
			                     'The skyward zoom in food prices is the dominant force behind the speed up in eurozone inflation.').

	llmChRF initDatasetWith: listOfcandidates and: listOfreferences.

	chrfFScore := llmChRF calculateChRF asFloat * 100.

	"totalF  16.3243"
	"self assert: chrfFScore equals: 16.3242."
	self assert: chrfFScore closeTo: 16.3243 precision: 4
]

{ #category : 'tests' }
LLMChRFTestBasedOnPaperImplemetation >> testCalculateChRF_3 [

	| listOfcandidates listOfreferences chrfFScore |
	listOfcandidates := OrderedCollection with:
		                    'El aumento de los precios en el mes de noviembre ha sido superior a lo esperado en los 13 países de la zona de euro, registrando - después del 2.6 por ciento del mes de octubre - una inflación anual del 3,1 por ciento - anunció la Oficina de Estadística de la Unión con sede en Luxemburgo.
'.
	listOfreferences := OrderedCollection with: (OrderedCollection with:
			                     'November price hikes were higher than expected in the 13 eurozone countries, with October''s 2.6 percent yr/yr inflation rate followed by 3.1 percent in November, the EU''s Luxembourg-based statistical office reported.
').

	llmChRF initDatasetWith: listOfcandidates and: listOfreferences.

	chrfFScore := llmChRF calculateChRF asFloat * 100.

	"totalF  18.2294""
	self assert: chrfFScore equals: 18.2703."
	self assert: chrfFScore closeTo: 18.2703 precision: 4
]

{ #category : 'tests' }
LLMChRFTestBasedOnPaperImplemetation >> testCalculateChRF_4 [

	| listOfcandidates listOfreferences chrfFScore |
	listOfcandidates := OrderedCollection with:
		                    'Las previsiones oficiales sólo daban como probable un 3 por ciento - anunció el Bloomberg.'.
	listOfreferences := OrderedCollection with: (OrderedCollection with:
			                     'Official forecasts predicted just 3 percent, Bloomberg said.').

	llmChRF initDatasetWith: listOfcandidates and: listOfreferences.

	chrfFScore := llmChRF calculateChRF asFloat * 100.

	"totalF  25.7960""
	self assert: chrfFScore equals: 18.2703."
	self assert: chrfFScore closeTo: 25.7960 precision: 4
]

{ #category : 'tests' }
LLMChRFTestBasedOnPaperImplemetation >> testCalculateChRF_5 [

	| listOfcandidates listOfreferences chrfFScore |
	listOfcandidates := OrderedCollection with:
		                    'Este ano también aumentó en un promedio de 16 por ciento en el triángulo comercial de oro de Budaörs la canasta habitual de navidad del diario Napi, pero en todos los hipermercados se registró un crecimiento muy superior a los mil HUF.'.
	listOfreferences := OrderedCollection with: (OrderedCollection with:
			                     'Prices In Napi''s usual Christmas basket were up by an average of 16 percent again this year in the Budaörs shopping triangle, with each of the giant supermarkets pushing prices up by well over a thousand forints.
').

	llmChRF initDatasetWith: listOfcandidates and: listOfreferences.

	chrfFScore := llmChRF calculateChRF asFloat * 100.

	"totalF  18.4734"
	
	"self assert: chrfFScore equals: 18.3981."
	self assert: chrfFScore closeTo: 18.3981 precision: 4
]

{ #category : 'tests' }
LLMChRFTestBasedOnPaperImplemetation >> testCalculateChRF_6 [

	| listOfcandidates listOfreferences chrfFScore |
	listOfcandidates := OrderedCollection with:
		                    'Fiesta, ambiente de Navidad, conciertos y buffet - así se divierte el poder.'.
	listOfreferences := OrderedCollection with: (OrderedCollection with:
			                     'Celebrations, Christmas spirit, concerts and smorgasbord - how the powerful party.').

	llmChRF initDatasetWith: listOfcandidates and: listOfreferences.

	chrfFScore := llmChRF calculateChRF asFloat * 100.

	"totalF  15.4491"
	
	self assert: chrfFScore equals: 15.449058281246106.
	self assert: chrfFScore closeTo: 15.4490 precision: 4
]

{ #category : 'tests' }
LLMChRFTestBasedOnPaperImplemetation >> testCalculateChRF_7 [

	| listOfcandidates listOfreferences chrfFScore |
	listOfcandidates := OrderedCollection with:
		                    'Hay que decidir si te adaptas a las pequeñas molestias o evitas conscientemente las situaciones confusas que pueden irritarle a otros.'.
	listOfreferences := OrderedCollection with: (OrderedCollection with:
			                     'The question is whether you get used to the minor annoyances or pick up the gauntlet and deliberately avoid dubious situations that can irritate others.').

	llmChRF initDatasetWith: listOfcandidates and: listOfreferences.

	chrfFScore := llmChRF calculateChRF asFloat * 100.

	"totalF  16.9773"
	
	self assert: chrfFScore equals: 16.977307322134894.
	self assert: chrfFScore closeTo: 16.9773 precision: 4
]

{ #category : 'tests' }
LLMChRFTestBasedOnPaperImplemetation >> testCalculateChRF_8 [

	| listOfcandidates listOfreferences chrfFScore |
	listOfcandidates := OrderedCollection with:
		                    'INTEGER FUNCTION SUM(a, b)'.
	listOfreferences := OrderedCollection with:
		                    (OrderedCollection with:
			                     'INTEGER FUNCTION PRODUCT(a, b)').


	llmChRF initDatasetWith: listOfcandidates and: listOfreferences.

	chrfFScore := llmChRF calculateChRF asFloat * 100.

	"totalF  65.3249"

	self assert: chrfFScore equals: 65.32487149474807.
]
