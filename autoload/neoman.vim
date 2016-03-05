let s:man_tag_depth = 0
let s:man_sect_arg = ''
let s:man_find_arg = '-w'
let s:man_cmd = 'man 2>/dev/null'
let s:man_extensions = '[glx]z\|bz2\|lzma\|Z'

try
  if !has('win32') && $OSTYPE !~? 'cygwin\|linux' && system('uname -s') =~? 'SunOS' && system('uname -r') =~? '^5'
    let s:man_sect_arg = '-s'
    let s:man_find_arg = '-l'
  endif
catch /E145:/
  " Ignore the error in restricted mode
endtry


function neoman#get_page(bang, editcmd, args) abort
  if len(a:args) > 2
    redraws! | echon "neoman: " | echohl ErrorMsg | echon "too many arguments" | echohl None
    return
  elseif empty(a:args)
    let [sect, page] = ['', expand('<cword>')]
    if empty(page)
      redraws! | echon "neoman: " | echohl ErrorMsg | echon "no identifier under cursor" | echohl None
      return
    endif
  elseif len(a:args) == 1
    let [sect, page] = ['', a:args[0]]
  elseif len(a:args) == 2
    let [sect, page] = a:args
  endif

  let [sect, page] = s:parse_page_and_section(sect, page)
  let where = s:find_page(sect, page)
  if where !~# '^\/'
    redraws! | echon "neoman: " | echohl ErrorMsg | echon "no manual entry for " . page | echohl None
    return
  endif

  if empty(sect)
    let sect = fnamemodify(system(where), ":t")
    if fnamemodify(sect, ":e") =~# '\%('.s:man_extensions.'\)\n'
      let sect = fnamemodify(sect, ":r")
    endif
    let sect = substitute(sect, '^[a-zA-Z_:.0-9-]\+\.\(\w\+\).*', '\1', '')
  endif

  exec 'let s:man_tag_buf_'.s:man_tag_depth.' = '.bufnr('%')
  exec 'let s:man_tag_lin_'.s:man_tag_depth.' = '.line('.')
  exec 'let s:man_tag_col_'.s:man_tag_depth.' = '.col('.')
  let s:man_tag_depth = s:man_tag_depth + 1

  let editcmd = a:editcmd
  if g:find_neoman_window == !a:bang
    if &filetype !=# 'neoman'
      let thiswin = winnr()
      wincmd b
      if winnr() > 1
        exe "norm! " . thiswin . "<C-W>w"
        while 1
          if &filetype == 'neoman'
            let editcmd = "edit"
            break
          endif
          wincmd w
          if thiswin == winnr()
            break
          endif
        endwhile
      endif
    endif
  endif

  silent exec editcmd . ' man://'.page.'('.sect.')'
  setlocal modifiable
  silent keepjumps norm! 1G"_dG
  let $MANWIDTH = winwidth(0)-1
  silent exec 'r!'.s:man_cmd.' '.s:cmd(sect, page).' | col -b'
  " Remove blank lines from top and bottom.
  while getline(1) =~ '^\s*$'
    silent keepjumps norm! gg"_dd
  endwhile
  while getline('$') =~ '^\s*$'
    silent keepjumps norm! G"_dd
  endwhile
  setlocal filetype=neoman
  return
endfunction

function neoman#pop_page() abort
  if s:man_tag_depth > 1
    let s:man_tag_depth = s:man_tag_depth - 1
    exec "let s:man_tag_buf=s:man_tag_buf_".s:man_tag_depth
    exec "let s:man_tag_lin=s:man_tag_lin_".s:man_tag_depth
    exec "let s:man_tag_col=s:man_tag_col_".s:man_tag_depth
    exec s:man_tag_buf."b"
    exec s:man_tag_lin
    exec "norm! ".s:man_tag_col."|"
    exec "unlet s:man_tag_buf_".s:man_tag_depth
    exec "unlet s:man_tag_lin_".s:man_tag_depth
    exec "unlet s:man_tag_col_".s:man_tag_depth
    unlet s:man_tag_buf s:man_tag_lin s:man_tag_col
  endif
endfunction

" Expects a string like 'access' or 'access(2)'.
function s:parse_page_and_section(sect, str) abort
  try
    let page = substitute(a:str, '\*\?\([a-zA-Z_:.0-9-]\+\).*', '\1', '')
    if page =~# '\.$'
      let page = strpart(page, 0, len(page)-1)
      return [page, a:sect]
    endif
    let sect = substitute(a:str, '\*\?[a-zA-Z_:.0-9-]\+(\([^()]*\)).*', '\1', '')
    if sect ==# page
      let sect = a:sect
    endif
  catch
    redraws! | echon "neoman: " | echohl ErrorMsg | echon "failed to parse ".a:str.'"' | echohl None
  endtry
  return [sect, page]
endfunction

function s:cmd(sect, page) abort
  if !empty(a:sect)
    return s:man_sect_arg.' '.a:sect.' '.a:page
  endif
  return a:page
endfunction

function s:find_page(sect, page) abort
  return system(s:man_cmd.' '.s:man_find_arg.' '.s:cmd(a:sect, a:page))
endfunction

function! neoman#Complete(ArgLead, CmdLine, CursorPos) abort
  let args = split(a:CmdLine)
  let len = len(args)
  if len == 1
    let page = ""
    let sect = ""
  elseif len == 2
    if empty(a:ArgLead)
      let page = ""
      let sect = args[1]
    else
      if a:ArgLead =~# '[^(]('
        let tmp = split(a:ArgLead, '(')
        let page = tmp[0]
        if len(tmp) == 1
          let sect = ""
        else
          let sect = substitute(tmp[1], ')', '', '')
        endif
      else
        let page = args[1]
        let sect = ""
      endif
    endif
  else
    let page = args[2]
    let sect = args[1]
  endif
  let mandirs_list = split(system(s:man_cmd.' '.s:man_find_arg), ':\|\n')
  let mandirs_list = filter(mandirs_list, 'index(mandirs_list, v:val, v:key+1)==-1')
  let mandirs = join(mandirs_list, ',')
  let candidates = globpath(mandirs, "*/" . page . "*." . sect . '*', 0, 1)
  for i in range(len(candidates))
    let candidates[i] = substitute((fnamemodify(candidates[i], ":t")),
          \ '\(.\+\)\.\%('.s:man_extensions.'\)\@!\([^.]\+\).*', '\1(\2)', "")
  endfor
  return candidates
endfunction
