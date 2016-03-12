if exists('g:loaded_neoman')
  finish
endif
let g:loaded_neoman = 1

if !exists("g:find_neoman_window")
  let g:find_neoman_window = 1
endif

command! -bang -nargs=? -complete=customlist,neoman#Complete -nargs=* Nman call
      \ neoman#get_page(<bang>0, 'edit', <q-args>)
command! -bang -nargs=? -complete=customlist,neoman#Complete -nargs=* Vnman call
      \ neoman#get_page(<bang>0, 'vsplit', <q-args>)
command! -bang -nargs=? -complete=customlist,neoman#Complete -nargs=* Snman call
      \ neoman#get_page(<bang>0, 'split', <q-args>)
command! -bang -nargs=? -complete=customlist,neoman#Complete -nargs=* Tnman call
      \ neoman#get_page(<bang>0, 'tabe', <q-args>)
