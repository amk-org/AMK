# AMK Language Design: "Mathematical Logics" Module
Drafted by *ssy* @ Oct, 2015
***

## 前言
我们希望，能从数理逻辑(Mathematical Logics)这一领域作为例子，实现AMK的第一个模块，从而证明该语言的可行性和实用性。相比分析等领域，逻辑较为简单，但是具备了基本的证明要素，十分适宜作为试水的模块。

## 继承 
继承AMK本身的所有语言特征。

## 具体的定义与说明
命题逻辑部分，参见 modules/logics/proposition.mamk。
	

## Source Code Example
A nonsense proof:

	theoreom A:
		require: P, R, Q
		conclude: a, b |- c
			where
				state a = R -> P Vee Q
				state b = not (R wedge Q)
				state c = R -> P
		proof:
			conclude a, b |- c [lemma B]

A sensible proof:

	theorem T:
		require: a, b
		conclude: a -> b |- a -> (a wedge b)
		proof:
			a -> b, a |- a [axiom belong] <1>
			a -> b, a |- a -> b <2> # using of axiom can be omitted
			a -> b, a |- b [axiom ->- 1,2] <t3>
			a -> b, a |- a wedge b [t3] <4>
			a -> b |- a -> (a wedge b) [4]
			

Check a theorem proof:

	$ amk 
	welcome to amk interpreter!
	> source A.amk
	source code loaded successfully!
	> check A
	Proof for A is not correct!
		@ line 10: conclude a -> b
	> quit

	