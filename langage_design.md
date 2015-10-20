# AMK Language Design: Overview
Drafted by *ssy* @ Oct, 2015
***


## 元素
### 类型 Type
AMK支持的基本类型为

* 推理形式

### 推理 Deduction

### 注释 Comment
采用#作为注释的符号，注释内容从#开始一直到行末。
#### 举例
> <span style="color:black">I am not a comment </span><span style="color:gray"># I am a comment </span>

<!--	I am not a comment <span style=""># I am a comment </span> -->

## 结构
### 模块 Module
AMK的设计初衷是为了在数学各个领域的证明中发挥相当的作用，由于这样的扩展性，决定采用模块(module)的形式，每个模块对应一个数学领域，包含该领域一些必须的内容等。不导入模块的解释器基本上可以认为只包含了逻辑。
#### 举例
	import "mathematical logics"

## 形式：书写习惯与语法
遵从证明书写的习惯，不打算将该语言做成Object-Oriented的
