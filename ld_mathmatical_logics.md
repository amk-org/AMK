# AMK Language Design: "Mathematical Logics" Module
Drafted by *ssy* @ Oct, 2015
***

## 前言
我们希望，能从数理逻辑(Mathematical Logics)这一领域作为例子，实现AMK的第一个模块，从而证明该语言的可行性和实用性。相比分析等领域，逻辑较为简单，但是具备了基本的证明要素，十分适宜作为试水的模块。

## 继承 
继承AMK本身的所有语言特征。

## 具体的定义与说明
参见 modules/logics/classic.mamk
	

## Source Code Example
A.amk

	1 import "mathmatical_logics"
	2 
	3 lemma B:
	4 	conclude 1
	5 	
	6 theorem name_of_the_theorem:
	7 	require: p, q
	8 	state a = p wedge q
	9 	state b = p -> not q
	10	conclude a -> b [lemma B]

-

	theoreom A:
		require: P, R, Q
		conclude: a, b |- c
			where
				state a = R -> P Vee Q
				state b = not (R wedge Q)
				state c = R -> P
		proof:
			conclude a, b |- c [lemma B]
-

	theorem T:
		require: a, b
		conclude: a -> b |- a -> (a wedge b)
		proof:
			a -> b, a |- a [axiom belong] <1>
			a -> b, a |- a -> b <2> # using of axiom can be omitted
			a -> b, a |- b [axiom ->- 1,2] <t3>
			a -> b, a |- a wedge b [t3] <4>
			a -> b |- a -> (a wedge b) [4]
			

尝试检查定理正确性

	$ amk 
	welcome to amk interpreter!
	> source A.amk
	source code loaded successfully!
	> check A
	Proof for A is not correct!
		@ line 10: conclude a -> b
	> quit

	