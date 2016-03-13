if exists("b:current_syntax")
  finish
endif
let b:current_syntax = "neoman"

" Get the CTRL-H syntax to handle backspaced text
runtime! syntax/ctrlh.vim

syn case   ignore
syn match  manReference       "\f\+(\([0-8][a-z]\=\|n\))"
syn match  manTitle           "^\f\+(\([0-8][a-z]\=\|n\)).*$"
syn match  manSectionHeading  "^[a-z][a-z ]*[a-z]$"
syn match  manSubHeading      "^\s\{3\}[a-z][a-z ]*[a-z]$"
syn match  manOptionDesc      "^\s\+[+-][a-z0-9]\S*"
syn match  manLongOptionDesc  "^\s\+--[a-z0-9-]\S*"

hi def link manTitle           Title
hi def link manSectionHeading  Statement
hi def link manOptionDesc      Constant
hi def link manLongOptionDesc  Constant
hi def link manReference       PreProc
hi def link manSubHeading      Function
hi def link manCFuncDefinition Function

if getline(1) =~# '^\f\+([23])'
  syntax include @cCode syntax/c.vim
  syn match manCFuncDefinition  display "\<\h\w*\>\s*("me=e-1 contained
  syn region manSynopsis start="^SYNOPSIS"hs=s+8 end="^\u\+\s*$"me=e-12 keepend contains=manSectionHeading,@cCode,manCFuncDefinition
endif
