#Documentation:Lex

##Keyword

	define import 
	therom axiom lemma 
	require conclude proof 
	where of 
	not wedge vee 


##Operator
Spaces in operators are not allowed.

	not vee wedge
	|-  |-|  ->  <->
	
	
##Identifier
Identifiers are strings that

1. starts with letters;
2. may contain letters, numbers, and '_'.

##Label
Labels contain letters, numbers and '_'.

Labels are wrapped with '<' and '>'.

Spaces in labels are not allowed.

Here are some examples below.

	<1>
	<belong>
	<_____yoooooo____>
	<3q_>


##Other Symbol
The symble to show which lemma or conclusion appeared before and now is used in this proof line.

	-[]
		Example:
		a |- b -[theorem t: <1> <2>] <1>

Parrens.

	(
	)
	
Comments

	#
		Example:
		#This is a comment.
	
Squere brackets

	[
	]

Colons

	: