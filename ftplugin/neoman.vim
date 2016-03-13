if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

setl buftype=nofile
setl noswapfile
setl nofoldenable
setl bufhidden=hide
setl nobuflisted
setl nomodified
setl readonly
setl nomodifiable
setl noexpandtab
setl tabstop=8
setl softtabstop=8
setl shiftwidth=8
setl nolist
setl foldcolumn=0
setl colorcolumn=0

if !exists("g:no_plugin_maps") && !exists("g:no_neoman_maps")
  nnoremap <silent> <buffer> <C-]>    :call neoman#get_page(g:find_neoman_window, 'edit', '')<CR>
  nnoremap <silent> <buffer> <C-t>    :call neoman#pop_page()<CR>
  nnoremap <silent> <buffer> q :q<CR>
endif
