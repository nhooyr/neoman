if exists("b:current_syntax")
  finish
endif

" Get the CTRL-H syntax to handle backspaced text
runtime! syntax/ctrlh.vim


syntax case  ignore
syntax match manReference       "\f\+(\%([0-8][a-z]\=\|n\))"
syntax match manTitle           "^[^[:space:]]\+\%((\%([0-8][a-z]\=\|n\))\)\=.*$"
syntax match manSectionHeading  "^\%(\%>1l\)\%([^[:space:]].*\)\=[^[:space:]]$"
syntax match manSubHeading      "^\s\{3\}\%([^[:space:]].*\)\=[^[:space:]]$"
syntax match manOptionDesc      "^\s\+[+-][a-z0-9]\S*"
syntax match manLongOptionDesc  "^\s\+--[a-z0-9-]\S*"

highlight default link manTitle          Title
highlight default link manSectionHeading Statement
highlight default link manOptionDesc     Constant
highlight default link manLongOptionDesc Constant
highlight default link manReference      PreProc
highlight default link manSubHeading     Function

if getline(1) =~# '^\f\+([23])'
  syntax include @cCode syntax/c.vim
  syntax match manCFuncDefinition  display "\<\h\w*\>\s*("me=e-1 contained
  syntax region manSynopsis start="^SYNOPSIS\|書式"hs=s+8 end="^[^[:space:]]\+\s*$"me=e-12 keepend contains=manSectionHeading,@cCode,manCFuncDefinition
  highlight default link manCFuncDefinition Function
endif

let b:current_syntax = "neoman"
