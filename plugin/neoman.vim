if exists('g:loaded_neoman')
  finish
endif
let g:loaded_neoman = 1

let g:neoman_find_window =
      \ get( g:, 'neoman_find_window', 1 )

command! -bang -complete=customlist,neoman#Complete -nargs=* Nman call
      \ neoman#get_page(<bang>0, 'edit', <f-args>)
command! -bang -complete=customlist,neoman#Complete -nargs=* Snman call
      \ neoman#get_page(<bang>0, 'split', <f-args>)
command! -bang -complete=customlist,neoman#Complete -nargs=* Vnman call
      \ neoman#get_page(<bang>0, 'vsplit', <f-args>)
command! -bang -complete=customlist,neoman#Complete -nargs=* Tnman call
      \ neoman#get_page(<bang>0, (tabpagenr()-1).'tabnew', <f-args>)
