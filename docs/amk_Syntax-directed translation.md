#	AMK 语法制导翻译
Drafted by *zhq* @ Nov, 2015
***

对公理、用户已经证明的定理、引理建立索引库。

索引库结构：

	struct theoremIndicator
		type # indicates theorem or axiom or lemma
		name
		require 
		conclude
	theoreIndicator[] theoremTable 

对于即将要验证的定理，需要依次对每一行proof进行验证。重点是去匹配require中的条件与conclude中的结论。

\* 建议在使用定理、引理和公理时指明require中需要的参数，此时只需要验证是否满条件。此条件可缺省，缺省是暴力枚举所有匹配参数。