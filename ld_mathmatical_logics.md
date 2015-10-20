# AMK Language Design: "Mathematical Logics" Module
Drafted by *ssy* @ Oct, 2015
***

## 前言 Preface
我们希望，能从数理逻辑(Mathematical Logics)这一领域作为例子，实现AMK的第一个模块，从而证明该语言的可行性和实用性。相比分析等领域，逻辑较为简单，但是具备了基本的证明要素，十分适宜作为试水的模块。

## Source Code Example
A.amk

	1 import "mathmatical logics"
	2 
	3 lemma B:
	4 	conclude 1
	5 	
	6 theorem A (lemma B):
	7 	state p, q
	8 	state a = p wedge q
	9 	state b = p -> not q
	10	conclude a -> b

尝试检查定理正确性

	$ amk source A.amk
	source code imported successfully!
	> check A
	Proof for A is not correct!
		@ line 10: conclude a -> b
	> quit

	