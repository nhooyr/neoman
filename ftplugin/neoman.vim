if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

if expand('%') !~# '^man:\/\/'
  " remove all those backspaces
  silent execute 'keepjumps %substitute,.\b,,ge'
  execute 'file '.'man://'.tolower(matchstr(getline(1), '^\S\+'))
  keepjumps 1
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
  nnoremap <silent> <buffer> <C-]>    :<C-U>call neoman#get_page(v:count, 'edit', expand('<cWORD>'))<CR>
  if &keywordprg !=# ':Nman'
    nmap   <silent> <buffer> <K>      <C-]>
  endif
  nnoremap <silent> <buffer> <C-t>    :call neoman#pop_tag()<CR>
  nnoremap <silent> <nowait><buffer>  q :q<CR>
endif

let b:undo_ftplugin = ''
