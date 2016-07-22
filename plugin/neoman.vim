if exists('g:loaded_neoman')
  finish
endif
let g:loaded_neoman = 1

let g:neoman_find_window =
      \ get( g:, 'neoman_find_window', 1 )

function! s:new_tab()
  if get( g:, 'neoman_tab_after', 0 ) == 1
    return 'tabnew'
  else
    return (tabpagenr()-1).'tabnew'
  endif
endfunction

command! -bang -complete=customlist,neoman#complete -nargs=* Nman call
      \ neoman#get_page(<bang>0, 'edit', <f-args>)
command! -bang -complete=customlist,neoman#complete -nargs=* Snman call
      \ neoman#get_page(<bang>0, 'split', <f-args>)
command! -bang -complete=customlist,neoman#complete -nargs=* Vnman call
      \ neoman#get_page(<bang>0, 'vsplit', <f-args>)
command! -bang -complete=customlist,neoman#complete -nargs=* Tnman call
      \ neoman#get_page(<bang>0, <SID>new_tab(), <f-args>)
