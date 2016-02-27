if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

setlocal iskeyword+=\.,-,(,),:
setlocal buftype=nofile
setlocal noswapfile
setlocal nofoldenable
setlocal bufhidden=hide
setlocal nobuflisted
setlocal nomodified
setlocal readonly
setlocal nomodifiable
setlocal noexpandtab
setlocal tabstop=8
setlocal softtabstop=8
setlocal shiftwidth=8
setlocal nolist
setlocal foldcolumn=0
setlocal colorcolumn=0

if !exists("g:no_plugin_maps") && !exists("g:no_neoman_maps")
  nnoremap <silent> <buffer> <C-]>    :call neoman#get_page(g:find_neoman_window, 'edit', '')<CR>
  nnoremap <silent> <buffer> <C-T>    :call neoman#pop_page()<CR>
  nnoremap <silent> <nowait><buffer>  q <C-W>c
  nnoremap <silent> <buffer> q :q<CR>
  if &keywordprg !=# ':Nman'
    nnoremap <silent> <buffer> K      :call neoman#get_page(g:find_neoman_window, 'edit', '')<CR>
  endif
endif

let b:undo_ftplugin = 'setlocal iskeyword<'
