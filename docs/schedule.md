# 时间和工作安排

### 开题报告
- 开题报告: 倪盛恺

### 10.18~10.25: 语言设计

- 语言设计文档：史舒扬
- 实现工具和阶段划分调查：倪盛恺
- 可能有参考性的工具`Coq`的调研：张浩千

### 10.25~11.1：词法分析
- 词法分析实现：倪盛恺
- 语法分析调研与草稿：张浩千
- 工具调研(flex+bison vs ANTLR)：史舒扬


### 11.1~11.12：语法分析
- 实现语法分析（构件AST）：史舒扬
- 修改词法分析器Lexer代码，并完成它的文档：倪盛恺
- SDT过程设计与草稿：张浩千


### 11.12~11.18：语法制导翻译SDT
- 语法制导翻译SDT：张浩千
- 写语法分析器Parser的文档：史舒扬
- 继续修改Lexer的Bug：倪盛恺

### 11.19：中期报告
- 中期报告：史舒扬

### 11.20~12.10：错误报告与完善测试

- 完善Translator的SDT过程: 张浩千
	- 增加更复杂的例子（添加完整的公理体系）
	- Debug
	
- Parser完善: 史舒扬
	- 错误报告
	- 增加对括号 '(' ')' 的支持
	- 存储AST节点的行号

- 实现外壳及模块的方式: 史舒扬


- Web 编辑器调研: 倪盛恺


### 12.10~12.24：进一步的工作

- 增加打印导出成功能（PDF）：张浩千
- Web编辑器与网站搭建：倪盛恺
- 尝试实现跳（一）步功能：史舒扬

### 12.31：结题报告
- 结题报告：张浩千

***

# Schedule and Work Allocation

## Current Status: Dec 10 -- Dec 24 Further Work

- Print Function: zhqc
- Web Interface and server: sanzunonyasama
- One-step inference: bsnsk

## Work done


### Oct 18 -- Oct 25 : language design

- Language design: bsnsk
- Tool and stage investigation: sanzunonyasama
- Coq investigation: zhqc

### Oct 25 -- Nov 1 : lexical analysis

- Lexical analysis using flex: sanzunonyasama
- Syntactical analysis draft: zhqc
- Investigation (Bison vs ANTLR, feature and usage): bsnsk

### Nov 1 -- Nov 12 : syntactical analysis

- Fix bugs and write doc for lexical part: sanzunonyasama
- Syntactical analysis and build AST: bsnsk
- Design Syntax-directed translation and write doc for that: zhqc

### Nov 12 -- Nov 18: (First demo) Syntax-directed translation

- Write doc for syntactical part: bsnsk
- Syntax-directed translation: zhqc
- Prepare slides for interim report: sanzunonyasama

### Nov 19 : Mid-Term Report
- Mid-Term Report


### Nov 20  -- Dec 10 : Error Reporting

- Syntax Refinement: bsnsk
	- Error Reporting
	- Support for '(' ')'
	- Storage of Line Number in AST Nodes

- Shell to implement modules: bsnsk

- Translator Refinement: zhqc
	- Debug
	- More Complex Examples

- Web Editors Investigation: sanzunonyasama

