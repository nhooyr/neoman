# neoman

Read manpages faster than superman!

![neoman in action](https://media.giphy.com/media/xT0BKrEeXPeKVMgb84/giphy.gif)

## ATTENTION
I just renamed the command to `:Nman`, if you were using it before, just edit any mappings or the functions in your `.zshrc`/`.bashrc`.

I've also changed `g:neoman_current_window` to `g:find_neoman_window`.

Instead of using `keywordprg` you should use the new `K` mapping described under [mappings](#mappings)

## Features
- Smart manpage autocompletion
- Open in a split/vsplit/tabe/current window
- Control whether or not to jump to closest (above/left) neoman window with the bang
- Open from inside a neovim terminal!
- Jump to manpages in specific sections through the manpage links
- Aware of modern manpages, e.g. sections are not just 1-8 anymore
- zsh/bash/fish support
- Can open paths to manpages!
- Support for multiple languages! If you will use it with another language, make sure to see `g:neoman_synopsis`.

## Install
Any plugin manager should work fine.

```vim
Plug 'nhooyr/neoman.vim' "vim-plug
```

## Usage
### Command
The command is as follows:

```vim
Nman[!] [sect] page
Nman[!] page[(sect)]
```

Several ways to use it, probably easier to explain with a few examples.

```vim
:Nman printf
:Nman 3 printf
:Nman printf(3)
```

Nman without any arguments will use the `WORD` (it strips anything after ')') under the cursor as the page.

For splitting there are the following commands (exact same syntax as `Nman`)

```vim
:Snman 3 printf "horizontal split
:Vnman 3 printf "verical split
:Tnman 3 printf "in a new tab
```

See `g:find_neoman_window` under settings for an explanation of the bang.

### Mappings
####Default Mappings
`<C-]>` to jump to a manpage under the cursor.  
`<C-t>` to jump back to the previous man page.  
`q` to quit

Here is a global `K` mapping to take you to the manpage under the cursor.

```vim
nnoremap <silent> K :Nman<CR>
```

This is preferred to setting `keywordprg` because `keywordprg` uses `iskeyword` and most filetypes don't have `(,)` in `iskeyword` which means `printf(3)` will take you to `printf(1)`.   The mapping fixes this by using `<cWORD>`.

Here is a custom mapping for a vertical split man page with the word under the cursor.

```vim
nnoremap <silent> <leader>mv :Vnman<CR>
```

Or perhaps you want to give the name of the manpage?

```vim
nnoremap <leader>mv :Vnman<Space>
```

Put them in autocmds to have them set only for neoman buffers.

### Command line integration
#### Neovim
You will need [nvr](https://github.com/mhinz/neovim-remote) for the super cool neovim terminal integration. If you do not want it, just use the vim version and obviously change the command to `nvim`.

#####zsh/bash
```zsh
function _nman {
	if (( $# > 3 )); then
		echo "Too many arguements"
		return
	fi
	local l=$#
	local -a page
	local page=(${@:1:$l-1})
	if [[ -z "$page" ]]; then
		echo "What manual page do you want?"
		return
	fi
	local tmp=$IFS
	IFS=$'\n' out=($(command man -w ${page[@]} 2>&1))
	local code=$?
	IFS=$tmp
	if [[ ${#out[@]} > 1 ]] && (( $# > 2 )); then
		echo "Too many manpages"
		return
	elif [[ $code != 0 ]]; then
		printf '%s\n' "${out[@]}"
		return
	fi
	if [[ -z $NVIM_LISTEN_ADDRESS ]]; then
		command nvim -c "${@: -1} ${page[*]}"
	else
		nvr --remote-send "<c-n>" -c "${@: -1} ${page[*]}"
	fi
}
function nman {
	_nman "$@" 'Nman'
}
function nman! {
	_nman "$@" 'Nman!'
}
```

#####fish
```fish
function _nman
	set page $argv[1..-2]
	if [ -z "$page" ]
		echo "What manual page do you want?"
		return
	end
	set out (eval "command man -w $page 2>&1")
	set code $status
	set manpage_count (echo "$out" | grep -c '.*')
	if [ $manpage_count -gt 1 ]
		echo "Too many manpages: $manpage_count"
		return
	else if [ $code != 0 ]
		echo "No manual entry for $page"
		return
	end
	if [ -z $NVIM_LISTEN_ADDRESS ]
		command nvim -c "$argv[-1] $page"
	else
		nvr --remote-send "<c-n>" -c "$argv[-1] $page"
	end
end
function nman
	_nman "$argv" 'Nman'
end
function nman!
	_nman "$argv" 'Nman!'
end
```

#####Splitting from neovim terminals
Say you want to vertical split a manpage from within a neovim terminal.  
Duplicate the two small functions, rename them to `vnman` and `vnman!` and change the string arguments of `_nman` to `'Vnman'` and `'Vnman!''`.  
Don't forget to add the autocomplete aliases from below but obviously rename them to fit.

#### Vim
#####zsh/bash
```zsh
function nman {
	if (( $# > 3 )); then
		echo "Too many arguements"
		return
	elif [[ -z $* ]]; then
		echo "What manual page do you want?"
		return
	fi
	local tmp=$IFS
	IFS=$'\n' out=($(command man -w $* 2>&1))
	local code=$?
	IFS=$tmp
	if [[ ${#out[@]} > 1 ]] && (( $# > 2 )); then
		echo "Too many manpages"
		return
	elif [[ $code != 0 ]]; then
		printf '%s\n' "${out[@]}"
		return
	fi
	vim -c "Nman $*"
}
```

#####fish
```fish
function nman
	if [ -z "$argv" ]
		echo "What manual page do you want?"
		return
    end
    set out (eval "command man -w $argv 2>&1")
    set code $status
    set manpage_count (echo "$out" | grep -c '.*')
    if [ $manpage_count -gt 1 ]
	    echo "Too many manpages: $manpage_count"
	    return
    else if [ $code != 0 ]
	    echo "No manual entry for $argv"
	    return
    end
    vim -c "Nman $argv"
end
```

#### Autocomplete
##### zsh
```zsh
compdef nman="man"

#add this as well if you are using neovim
compdef nman!="man"
```

##### bash
```bash
complete -o default -o nospace -F _man nman

#add this as well if you are using neovim
complete -o default -o nospace -F _man nman!
```

##### fish
```fish
complete --command nman --wraps=man

#add this as well if you are using neovim
complete --command nman! --wraps=man
```

Use `nman`/`nman!` to open the manpages. `nman!` works the same way as `:Nman!`, but obviously its only available for neovim. You have to be connected remotely in order to find the neoman window, otherwise it doesn't matter, see `g:find_neoman_window`.

I've really only tested this with zsh, if you have any problems with `bash`/`fish`, please open a issue!

### Settings
`g:find_neoman_window`  
If this option is set, neoman will first attempt to find the current neoman window before opening a new one. The bang on `:Nman` will alternate on this behavior. So if this option is set, the bang will make it act like as if it is not set, and vice versa.  
By default this is set.

`g:no_neoman_maps`  
If set, no mappings are made in neoman buffers. By default it is not set.

`g:neoman_synopsis`  
If you are using a language other than english, set this to whatever the 'Synopsis' translates to in your language. This allows neoman to highlight the c code in manpages of sections 2 and 3.  
Just run `man acct` from the command line. Set this to the line above the '#include' (it is a regex if you want to do multiple matches)
By default it is set to just `SYNOPSIS`, as most people will be using english manpages.

## Contributing
I'm very open to new ideas, new features, anything really ;) . Open up an issue, send me a PR, or email.

TODO:
-----
- [ ] Vim docs
- [x] Rewrite for clean code, check PR #15 to test it!
- [ ] Maybe parse manpage links that have been seperated e.g `zshop-  
tions(1)`
