if exists("b:current_syntax")
  finish
endif

" Get the CTRL-H syntax to handle backspaced text
runtime! syntax/ctrlh.vim

let s:l = line('$')

syntax case  ignore
syntax match manReference       "\f\+(\%([0-8][a-z]\=\|n\))"
syntax match manTitle           "^\%1l\S\+\%((\%([0-8][a-z]\=\|n\))\)\=.*$"
execute 'syntax match manSectionHeading  "^\%(\%>1l\%<'.s:l.'l\)\%(\S.*\)\=\S$"'
syntax match manSubHeading      "^\s\{3\}\%(\S.*\)\=\S$"
syntax match manOptionDesc      "^\s\+[+-][a-z0-9]\S*"
syntax match manLongOptionDesc  "^\s\+--[a-z0-9]\S*"

highlight default link manTitle          Title
highlight default link manSectionHeading Statement
highlight default link manOptionDesc     Constant
highlight default link manLongOptionDesc Constant
highlight default link manReference      PreProc
highlight default link manSubHeading     Function

if !exists('g:neoman_synopsis')
  let g:neoman_synopsis = 'SYNOPSIS'
endif

syntax include @cCode syntax/c.vim
syntax match manCFuncDefinition  display "\<\h\w*\>\s*("me=e-1 contained
execute 'syntax region manSynopsis start="^'.g:neoman_synopsis.'"hs=s+8 end="^\S\+\s*$"me=e-12 keepend contains=manSectionHeading,@cCode,manCFuncDefinition'
highlight default link manCFuncDefinition Function

let b:current_syntax = "neoman"
