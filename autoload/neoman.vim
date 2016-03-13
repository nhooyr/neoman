let s:man_cmd = 'man 2>/dev/null'
let s:man_extensions = '[glx]z\|bz2\|lzma\|Z'
let s:neoman_tag_stack = []
function! neoman#get_page(bang, editcmd, ...) abort
  if empty(a:000)
    let fpage = expand('<cWORD>')
    if empty(fpage)
      call s:error("no WORD under cursor")
      return
    endif
  elseif len(a:000) > 2
    call s:error('too many arguments')
    return
  elseif len(a:000) == 1
    let fpage = a:000[0]
  else
    let fpage = a:000[1].'('.a:000[0].')'
  endif

  let [page, sect] = s:parse_page_and_section(fpage)
  if empty(page)
    call s:error('invalid manpage name '.fpage)
    return
  endif
  let path = s:find_page(sect, page)
  if v:shell_error
    call s:error("no manual entry for ".fpage)
    return
  elseif empty(sect) && page !~# '\/'
    let sect = s:parse_sect(path)
  endif

  call s:push_stack()

  if g:find_neoman_window != a:bang && &filetype !=# 'neoman'
    let cmd = s:find_neoman(a:editcmd)
  else
    let cmd = a:editcmd
  endif

  call s:read_page(sect, page, cmd)
endfunction

function! neoman#pop_tag_stack() abort
  if !empty(s:neoman_tag_stack)
    exec s:neoman_tag_stack[-1]['buf'].'b'
    exec s:neoman_tag_stack[-1]['lin']
    exec 'norm! '.s:neoman_tag_stack[-1]['col'].'|'
    call remove(s:neoman_tag_stack, -1)
  endif
endfunction

function! s:push_stack() abort
  let s:neoman_tag_stack = add(s:neoman_tag_stack, {
        \ 'buf': bufnr('%'),
        \ 'lin': line('.'),
        \ 'col': col('.')
        \ })
endfunction

function! s:find_neoman(cmd) abort
  if winnr('$') > 1
    let thiswin = winnr()
    while 1
      if &filetype == 'neoman'
        return 'edit'
      endif
      wincmd w
      if thiswin == winnr() | break | endif
    endwhile
  endif
  return a:cmd
endfunction

" parses the sect/page out of 'page(sect)'
function! s:parse_page_and_section(fpage) abort
  let ret = split(a:fpage, '(')
  if empty(ret) || len(ret) > 2
    return ['', '']
  elseif len(ret) == 1
    return [ret[0], '']
  elseif ret[1] =~# '^\f\+)\f*$'
    let iret = split(ret[1], ')')
    return [ret[0], iret[0]]
  endif
endfunction

function! s:find_page(sect, page) abort
  return split(system(s:man_cmd.' -w '.a:sect.' '.a:page).' 2>&1', '\n')[0]
endfunction

function! s:parse_sect(path) abort
  let tail = fnamemodify(a:path, ':t')
  if fnamemodify(tail, ":e") =~# '\%('.s:man_extensions.'\)\n'
    let tail = fnamemodify(tail, ':r')
  endif
  return substitute(tail, '\f\+\.\([^.]\+\)', '\1', '')
endfunction

function! s:read_page(sect, page, cmd)
  silent exec a:cmd 'man://'.a:page.(empty(a:sect)?'':'('.a:sect.')')
  setl modifiable
  " remove all the text, incase we already loaded the manpage before
  silent keepjumps norm! gg"_dG
  let $MANWIDTH = winwidth(0)-1
  " read manpage into buffer
  silent exec 'r!'.s:man_cmd.' '.a:sect.' '.a:page.' | col -b'
  " remove blank lines from top and bottom.
  while getline(1) =~ '^\s*$'
    silent keepjumps 1delete _
  endwhile
  while getline('$') =~ '^\s*$'
    silent keepjumps $delete _
  endwhile
  setl ft=neoman
endfunction


function! s:error(msg) abort
  redraws!
  echon "neoman: "
  echohl ErrorMsg
  echon a:msg
  echohl None
endfunction

function! neoman#Complete(ArgLead, CmdLine, CursorPos) abort
  let args = split(a:CmdLine)
  let l = len(args)
  if (l > 1 && args[1] =~# ')\f*$') || l > 3 || a:ArgLead =~# ')$'
    return
  elseif l == 3
    if empty(a:ArgLead)
      return
    endif
    let sect = args[1]
    let page = args[2]
  elseif l == 2
    if empty(a:ArgLead)
      let page = ""
      let sect = args[1]
    elseif a:ArgLead =~# '^\f\+(\f*$'
      let tmp = split(a:ArgLead, '(')
      let page = tmp[0]
      let sect = substitute(get(tmp, 1, '*'), ')$', '', '')
    else
      let page = args[1]
      let sect = '*'
    endif
  else
    let page = ''
    let sect = '*'
  endif
  return s:get_candidates(page, sect)
endfunction

function! s:get_candidates(page, sect) abort
  let mandirs = s:get_man_dirs()
  let candidates = globpath(mandirs, "*/" . a:page . "*." . a:sect, 0, 1)
  let find = '\(.\+\)\.\%('.s:man_extensions.'\)\@!\'
  if a:sect != '*'
    let find .= '%([^.]\+\).*'
    let repl = '\1'
  else
    let find .= '([^.]\+\).*'
    let repl = '\1(\2)'
  endif
  if a:sect ==# '*' && a:page =~# '\/'
    "TODO why does this complete the last one automatically
    let candidates = glob(a:page.'*', 0, 1)
  else
    for i in range(len(candidates))
      let candidates[i] = substitute((fnamemodify(candidates[i], ":t")),
            \ find, repl, "")
    endfor
  endif
  return candidates
endfunction

function! s:get_man_dirs() abort
  let mandirs_list = split(system(s:man_cmd.' -w'), ':\|\n')
  return join(filter(mandirs_list, 'index(mandirs_list, v:val, v:key+1)==-1'), ',')
endfunction
