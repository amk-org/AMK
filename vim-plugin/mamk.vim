syntax keyword mamk TYPE OPERATOR AXIOM THEOREM
syntax keyword mamk_type list set
syntax keyword mamk_state require conclude proof of
syntax keyword todo contained TODO FIXME
syntax match comment "#.*$" contains=todo
highlight link mamk Identifier
highlight link mamk_type Type
highlight link comment Comment
highlight link mamk_state Statement
highlight link todo Todo
