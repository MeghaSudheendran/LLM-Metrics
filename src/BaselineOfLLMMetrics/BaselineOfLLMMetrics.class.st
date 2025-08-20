Class {
	#name : 'BaselineOfLLMMetrics',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfLLMMetrics',
	#package : 'BaselineOfLLMMetrics'
}

{ #category : 'baselines' }
BaselineOfLLMMetrics >> baseline: spec [

    <baseline>
    spec for: #common do: [ 
        spec
            baseline: 'AINgramModel'
            with: [ spec repository: 'github://pharo-ai/NgramModel/src' ].
       ].
]
