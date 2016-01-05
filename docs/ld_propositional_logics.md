# AMK Language Design: "Mathematical Logics" Module
By *Shuyang Shi* @ Oct, 2015
***

## 前言 Preface
我们希望，能从数理逻辑(Mathematical Logics)这一领域作为例子，实现AMK的第一个模块，从而证明该语言的可行性和实用性。相比分析等领域，逻辑较为简单，但是具备了基本的证明要素，十分适宜作为试水的模块。

We use Mathematical Logics (propositional logics) as an example, and as the first module of our AMK project, to prove the AMK project is practicable and utility. Unlike the analysis field, logic is simpler in expression but equipped with most elements of mathematical proofs, which make it suitable as the first module. 

## 继承 Inheritance
继承AMK本身的所有语言特征。

All the features of AMK language.

## 具体的定义与说明 Specific Definition and Demonstration
命题逻辑部分，参见 `modules/logics/proposition.mamk`。

To view the specific definition of the propositional part, refer to 
 `modules/logics/proposition.mamk`.
 
## Source Code Example
更多的例子可以见网站。

Visit our website to see more examples.

```code
import logics.proposition

theorem belong2:
	require:
		define a of statement
		define b of statement
		define c of statement
		define d of statement
	conclude:
		a,b,c|-c
	proof:
		a,b,c|-a -[belong] <1>
		a,b,(a wedge b) wedge c|- (a wedge b) wedge c -[belong] <2>
		a,b,c|-c -[belong] <2>
```

```code
import logics.proposition

theorem belong2:
	require:
		define a of statement
		define b of statement
		define c of statement
		define d of statement
	conclude:
		a,b,c|-c
	proof:
		a,b,c|-a -[belong] <1>
		a,b,a wedge b|- a wedge b -[belong] <2>
		a,b,c|-c -[belong] <2>

theorem belong3:
	require:
		define x of statement
		define y of statement
		define z of statement
		define p of statement
	conclude:
		x,y,z|-y
	proof:
		x,y,z|-y -[belong2] <2>
```

```code
import logics.proposition

theorem zero_step_and_one_step_at_one_time:
	require:
		define a of statement
		define b of statement
	conclude:
		not a -> not b |- b -> a
	proof:
		not a, not a -> not b, b |- not a -[belong] <e1>
		not a, not a -> not b, b |- not a -> not b -[belong] <e2>
#		not a, not a -> not b, b |- not b -[theorem contain_cancellation: <x><e1>] <e3>
		not a, not a -> not b, b |- b -[belong] <e4>
		not a -> not b, b |- a -[theorem not_cancellation: <x> <x>] <e5> # <x>s are here
		not a -> not b |- b -> a -[contain_introduction]
```		

			
