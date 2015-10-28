#	AMK 词法分析
Drafted by *zhq* @ Oct, 2015
***
	theorem 
	
	theorem T:
		require: a, b
		conclude: a -> b |- a -> (a wedge b)
		proof:
			a -> b, a |- a [axiom belong] <1>
			a -> b, a |- a -> b <2> # using of axiom can be omitted
			a -> b, a |- b [axiom ->- : 1,2] <t3>
			a -> b, a |- a wedge b [:t3] <4>
			a -> b |- a -> (a wedge b) [4]