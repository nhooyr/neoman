if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

if expand('%') !~# '^man:\/\/'
  silent execute 'file '.'man://'.tolower(substitute(getline(1), '^\(\S\+\).*$', '\1', 0))
  call neoman#normalizeBuffer()
endif

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

if !exists('g:no_plugin_maps') && !exists('g:no_neoman_maps')
  nnoremap <silent> <buffer> <C-]>    :call neoman#get_page(g:neoman_find_window, 'edit')<CR>
  nmap     <silent> <buffer> <K>      <C-]>
  nnoremap <silent> <buffer> <C-t>    :call neoman#pop_tag()<CR>
  nnoremap <silent> <nowait><buffer>  q :q<CR>
endif

let b:undo_ftplugin = ''
