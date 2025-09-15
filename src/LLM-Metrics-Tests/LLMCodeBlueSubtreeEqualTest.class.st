Class {
	#name : 'LLMCodeBlueSubtreeEqualTest',
	#superclass : 'TestCase',
	#instVars : [
		'codeBleuAST'
	],
	#category : 'LLM-Metrics-Tests',
	#package : 'LLM-Metrics-Tests'
}

{ #category : 'running' }
LLMCodeBlueSubtreeEqualTest >> setUp [
	super setUp.

	codeBleuAST := LLMCodeBleuAST new.
]

{ #category : 'tests' }
LLMCodeBlueSubtreeEqualTest >> testNoMatchedSubtree [

	| subtrees1 subtrees2 |

	subtrees1 := FASTFortranStatementBlock new
		addStatement: FASTFortranEntryStatement new;
		addStatement: FASTFortranExitStatement new;
		 yourself.
	subtrees2 := FASTFortranStatementBlock new
		addStatement: FASTFortranDoStatement new;
		addStatement: FASTFortranElseStatement new;
		yourself.

	self deny: (codeBleuAST subtree: subtrees1 equals: subtrees2)
]

{ #category : 'tests' }
LLMCodeBlueSubtreeEqualTest >> testOneMatchedSubtree [

	| subtrees1 subtrees2 |
	subtrees1 := FASTFortranStatementBlock new
		             addStatement: FASTFortranEntryStatement new;
		             addStatement: FASTFortranExitStatement new;
		             yourself.
	subtrees2 := FASTFortranStatementBlock new
		             addStatement: FASTFortranEntryStatement new;
		             addStatement: FASTFortranIfBlockStatement new;
		             addStatement: FASTFortranElseStatement new;
		             addStatement: FASTFortranExitStatement new;
		             yourself.

	self deny: (codeBleuAST subtree: subtrees1 equals: subtrees2)
]

{ #category : 'tests' }
LLMCodeBlueSubtreeEqualTest >> testRootEqualChildNotEqual [

	| subtrees1 subtrees2 |

	subtrees1 := FASTFortranStatementBlock new
		             addComment: FASTFortranComment new;
		             yourself.
	subtrees2 := FASTFortranStatementBlock new
		             addStatement:
			             FASTFortranVariableDeclarationStatement new;
		             yourself.

	self deny: (codeBleuAST subtree: subtrees1 equals: subtrees2)
]

{ #category : 'tests' }
LLMCodeBlueSubtreeEqualTest >> testRootEqualSomeChildNotEqual [

	| subtrees1 subtrees2 |
	subtrees1 := FASTFortranVariableDeclarationStatement new
		             declaredType: FASTFortranRealType new;
		             addDeclarator: FASTFortranVariableDeclarator new;
		             yourself.
	subtrees2 := FASTFortranVariableDeclarationStatement new
		             declaredType: FASTFortranIntegerType new;
		             addDeclarator: FASTFortranVariableDeclarator new;
		             yourself.

	self deny: (codeBleuAST subtree: subtrees1 equals: subtrees2)
]

{ #category : 'tests' }
LLMCodeBlueSubtreeEqualTest >> testRootNotEqualChildrenEqual [

	| subtrees1 subtrees2 |
	subtrees1 := FASTFortranFunction new
		             statementBlock: FASTFortranStatementBlock new;
		             addComment: FASTFortranComment new ;
		             yourself.
	subtrees2 := FASTFortranSubroutine new
		             statementBlock: FASTFortranStatementBlock new;
		             addComment: FASTFortranComment new;
		             yourself.

	self deny: (codeBleuAST subtree: subtrees1 equals: subtrees2)
]

{ #category : 'tests' }
LLMCodeBlueSubtreeEqualTest >> testSameOneChild [

	| subtrees1 subtrees2 |

	subtrees1 := FASTFortranSubroutine new statementBlock:
			             FASTFortranStatementBlock new.
	subtrees2 := FASTFortranSubroutine new statementBlock:
		             FASTFortranStatementBlock new.

	self assert: (codeBleuAST subtree: subtrees1 equals: subtrees2)
]

{ #category : 'tests' }
LLMCodeBlueSubtreeEqualTest >> testWithDepth3 [

	| subtrees1 subtrees2 |
	subtrees1 := FASTFortranSubroutine new
		statementBlock: FASTFortranStatementBlock new;
		yourself.
	subtrees2 := FASTFortranSubroutine new
		statementBlock: (FASTFortranStatementBlock new
			addStatement: FASTFortranExitStatement new;
			yourself) ;
		yourself.

	self assert: (codeBleuAST subtree: subtrees1 equals: subtrees2)
]

{ #category : 'tests' }
LLMCodeBlueSubtreeEqualTest >> testWithDifferentProperty [

	| subtrees1 subtrees2 |
	subtrees1 := FASTFortranSubroutine new
		             statementBlock: FASTFortranStatementBlock new;
		             name: 'sum';
		             yourself.
	subtrees2 := FASTFortranSubroutine new
		             statementBlock: FASTFortranStatementBlock new;
		             name: 'product';
		             yourself.

	self assert: (codeBleuAST subtree: subtrees1 equals: subtrees2)
]
