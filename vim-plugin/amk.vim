syntax keyword amk_type list set
syntax keyword amk_statement of require conclude proof define
syntax keyword func axiom lemma theorem import
syntax keyword todo contained TODO FIXME
syntax match comment "#.*$" contains=todo
highlight link amk_type Type
highlight link amk_statement Statement
highlight link comment Comment
highlight link todo Todo
highlight link func Identifier
