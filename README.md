# AMK Brief
AMK (Anti-Min-Ke) is a home-made language for people writing and checking mathematical proofs. It aims to
- standardize proof writings, 
- automatically check the correctness of proofs, and
- (future) do semi-automatically proof.

# Documents of AMK Project
Please refer to the following links to documents:

- Project Page: [AMK Project](https://bsnsk.github.io/AMK)

- [Schedule and Work Allocation](#schedule)

- Design Documents

	- [AMK Language Design: Overview](docs/language_design.md)

	- [AMK Language Design: Propositional logics](docs/ld_propositional_logics.md)

	- [Lexical Analysis](docs/lex.md)
	
	- [Syntactical Analysis & AST](docs/syntax.md)

- Code Progress Documents
	
	- [src/README](src/README.md)

<h1 id="schedule"> Schedule and Work Allocation</h1>

## Current Status: Nov 20  -- Dec 3 : Error Reporting

- Syntax Refinement: bsnsk
	- Error Reporting System
	- Support for '(' ')'
	- Storage of Line Number in AST Nodes

- Shell to implement modules: bsnsk

- Translator Refinement: zhqc
	- Debug
	- More Complex Examples

- Lexer Comments : sanzunonyasama
- Web Libraries Investigation: sanzunonyasama

## Future Schedule

- Further Support
	- Contact Mr. Wang
- Web Interface

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
