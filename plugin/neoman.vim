if exists('g:loaded_neoman')
  finish
endif
let g:loaded_neoman = 1

if !exists("g:find_neoman_window")
  let g:find_neoman_window = 1
endif

if !exists('g:neoman_synopsis')
  let g:neoman_synopsis = 'SYNOPSIS'
endif

command! -bang -complete=customlist,neoman#Complete -nargs=* Nman call
      \ neoman#get_page(<bang>0, 'edit', <f-args>)
command! -bang -complete=customlist,neoman#Complete -nargs=* Snman call
      \ neoman#get_page(<bang>0, 'split', <f-args>)
command! -bang -complete=customlist,neoman#Complete -nargs=* Vnman call
      \ neoman#get_page(<bang>0, 'vsplit', <f-args>)
command! -bang -complete=customlist,neoman#Complete -nargs=* Tnman call
      \ neoman#get_page(<bang>0, 'tabe', <f-args>)
