let s:man_cmd = 'man 2>/dev/null'
let s:man_extensions = '[glx]z\|bz2\|lzma\|Z'
let s:neoman_tag_depth = []
" full page means 'page(sect)' or 'page'
function! neoman#get_page(bang, editcmd, fullpage) abort
  if empty(a:fullpage)
    let fpage = expand('<cword>')
    if empty(fpage)
      call s:error("no keyword under cursor")
      return
    endif
  else
    let fpage = a:fullpage
  endif
  let [page, sect] = s:parse_page_and_section(fpage)
  let path = s:find_page(sect, page)
  if path !~# '^\/'
    call s:error("no manual entry for ".page.'('.sect.')')
    return
  elseif empty(sect)
    let sect = s:parse_sect(path)
  endif

  let s:neoman_tag_depth = add(s:neoman_tag_depth, {
        \ 'buf': bufnr('%'),
        \ 'lin': line('.'),
        \ 'col': col('.')
        \ })

  if g:find_neoman_window != a:bang && &filetype !=# 'neoman'
    let cmd = s:find_neoman() ? 'edit' : a:editcmd
  else
    let cmd = a:editcmd
  endif
  silent exec cmd 'man://'.page.'('.sect.')'
  setl modifiable
  silent keepjumps norm! gg"_dG
  let $MANWIDTH = winwidth(0)-1

  " read manpage into buffer
  silent exec 'r!'.s:man_cmd.' '.sect.' '.page.' | col -b'
  " remove blank lines from top and bottom.
  while getline(1) =~ '^\s*$'
    silent keepjumps norm! gg"_dd
  endwhile
  while getline('$') =~ '^\s*$'
    silent keepjumps norm! G"_dd
  endwhile
  setl filetype=neoman
endfunction

function! neoman#pop_page() abort
  if !empty(s:neoman_tag_depth)
    exec s:neoman_tag_depth[-1]['buf'].'b'
    exec s:neoman_tag_depth[-1]['lin']
    exec 'norm! '.s:neoman_tag_depth[-1]['col'].'|'
    call remove(s:neoman_tag_depth, -1)
  endif
endfunction

function! s:find_neoman() abort
  let thiswin = winnr()
  wincmd b
  if winnr() > 1
    exe "norm! " . thiswin . "<C-W>w"
    while 1
      if &filetype == 'neoman'
        return 1
      endif
      wincmd w
      if thiswin == winnr() | break | endif
    endwhile
  endif
  return 0
endfunction

" parses the sect/page out of 'page(sect)'
function! s:parse_page_and_section(fullpage) abort
  let ret = split(a:fullpage, '(')
  if get(ret, 1) !~# ')$'
    return [ret[0], '']
  endif
  "return page, and sect without bracket at the end
  return [ret[0], ret[1][:-2]]
endfunction

function! s:find_page(sect, page) abort
  let ret = split(system(s:man_cmd.' -w '.a:sect.' '.a:page), '\n')
  return empty(ret) ? '' : ret[0]
endfunction

function! s:parse_sect(path) abort
  let tail = fnamemodify(a:path, ':t')
  if fnamemodify(tail, ":e") =~# '\%('.s:man_extensions.'\)\n'
    let tail = fnamemodify(tail, ':r')
  endif
  return substitute(tail, '.*\.\([^.]\+\)$', '\1', '')
endfunction

function! s:error(msg) abort
  redraws! | echon "neoman: " | echohl ErrorMsg | echon a:msg | echohl None
endfunction

function! neoman#Complete(ArgLead, CmdLine, CursorPos) abort
  let args = split(a:CmdLine)
  let l = len(args)
  if empty(a:ArgLead)
    if l > 1
      return
    endif
    let page = ''
    let sect = ''
  elseif a:ArgLead =~# '[^(]('
    let tmp = split(a:ArgLead, '(')
    let page = tmp[0]
    let sect = substitute(get(tmp, 1), ')', '', '')
  else
    let page = args[1]
    let sect = ''
  endif
  let mandirs = s:get_man_dirs()
  let candidates = globpath(mandirs, "*/" . page . "*." . sect . '*', 0, 1)
  for i in range(len(candidates))
    let candidates[i] = substitute((fnamemodify(candidates[i], ":t")),
          \ '\(.\+\)\.\%('.s:man_extensions.'\)\@!\([^.]\+\).*', '\1(\2)', "")
  endfor
  return candidates
endfunction

function! s:get_man_dirs() abort
  let mandirs_list = split(system(s:man_cmd.' -w'), ':\|\n')
  return join(filter(mandirs_list, 'index(mandirs_list, v:val, v:key+1)==-1'), ',')
endfunction
