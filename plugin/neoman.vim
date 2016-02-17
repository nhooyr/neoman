" Copyright (C) 2016  Sethi, Anmol <anmol@aubble.com>
" Author: Sethi, Anmol <anmol@aubble.com>
" 
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
" 
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
" 
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.

if exists('g:loaded_neoman')
  finish
endif
let g:loaded_neoman = 1

if !exists("g:find_neoman_window")
  let g:find_neoman_window = 1
endif

command! -bang -complete=customlist,neoman#Complete -nargs=* Nman call
      \ neoman#get_page(<bang>0, 'edit', split(<q-args>, ' '))
command! -bang -complete=customlist,neoman#Complete -nargs=* Vnman call
      \ neoman#get_page(<bang>0, 'vsplit', split(<q-args>, ' '))
command! -bang -complete=customlist,neoman#Complete -nargs=* Snman call
      \ neoman#get_page(<bang>0, 'split', split(<q-args>, ' '))
command! -bang -complete=customlist,neoman#Complete -nargs=* Tnman call
      \ neoman#get_page(<bang>0, 'tabe', split(<q-args>, ' '))
