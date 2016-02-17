# neoman

Read manpages faster than superman!

![neoman in action](https://media.giphy.com/media/xT0BKrEeXPeKVMgb84/giphy.gif)

## ATTENTION
I just renamed the command to `:Nman`, if you were using it before, just edit any mappings or the functions in your `.zshrc`/`.bashrc`.

I've also changed `g:neoman_current_window` to `g:find_neoman_window`.

## Features
- Manpage autocompletion
- Open in a split/vsplit/tabe or current window
- Open from inside a neovim terminal!
- Jump to manpages in specific sections through the manpage links
- Aware of modern manpages, e.g. sections are not just 1-8 anymore
- Fish Support

## Install
Any plugin manager should work fine.

```vim
Plug 'nhooyr/neoman.vim' "vim-plug
```

## Usage
### Command
The command is as follows:

```vim
Nman[!] [{sect}] {page}
Nman[!] {page}[({sect})]
```

Several ways to use it, probably easier to explain with a few examples.

```vim
:Nman printf
:Nman 3 printf
:Nman printf(3)
```

Nman without any arguments will use `<cword>` as the page.

For splitting/tabs there are the following commands

```vim
:Snman! 3 printf "horizontal split
:Vnman! 3 printf "verical split
:Tnman! 3 printf "in a new tab
```

See `g:find_neoman_window` under settings for an explanation of the bang.

### Mappings
`<c-]>` or `K` to jump to a manpage under the cursor.  
`<c-t>` to jump back to the previous man page.  
'q' to quit

You can also set the following in your `init.vim`/`.vimrc` and use `K` to jump to manpages globally for the word under the cursor.

```vim
set keywordprg=:Nman
```

Here is a custom mapping for a vertical split man page with the word under the cursor.

```vim
nnoremap <silent> <leader>mv :Vnman<CR>
```

Or perhaps you want to give the name of the manpage?

```vim
nnoremap <leader>mv :Vnman 
```

Note the trailing space at `:Vnman `

### Command line integration
#### Neovim
You will need [nvr](https://github.com/mhinz/neovim-remote) for the super cool neovim terminal integration. If you do not want it, just use the vim version and obviously change the command to `nvim`.

Add the following functions to your `.zshrc`/`.bashrc`

```zsh
function _nman {
	local l=$#
	local page=(${@:1:$l-1})
	if [[ -z "$page" ]]; then
		echo "What manual page do you want?"
		return
	fi
	local tmp=$IFS
	IFS=$'\n' out=($(command man -w ${page[@]} 2>&1))
	local code=$?
	IFS=$tmp
	if [[ ${#out[@]} > 1 ]]; then
		echo "Too many manpages"
		return
	elif [[ $code != 0 ]]; then
		echo "No manual entry for ${page[*]}"
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

or the following to your config.fish

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

#### Vim

Add the following functions to your `.zshrc`/`.bashrc`

```zsh
function nman {
	if [[ -z $* ]]; then
		echo "What manual page do you want?"
		return
	fi
	local tmp=$IFS
	IFS=$'\n' out=($(command man -w $* 2>&1))
	local code=$?
	IFS=$tmp
	if [[ ${#out[@]} > 1 ]]; then
		echo "Too many manpages"
		return
	elif [[ $code != 0 ]]; then
		echo "No manual entry for $*"
		return
	fi
	vim -c "Nman $*"
}
```

or the following to your config.fish

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

Use `nman`/`nman!` to open the manpages. `nman!` works the same way as `:Nman!`.

I've really only tested this with zsh, if you have any problems with `bash`/`fish`, please open a issue!

### Settings
`g:find_neoman_window`  
If this option is set, neoman will first attempt to find the current neoman window before opening a new one. The bang on `:Nman` will alternate on this behavior. So if this option is set, the bang will make it act like as if it is not set, and vice versa.  
By default this is set.

`g:no_neoman_maps`  
If set, no mappings are made in neoman buffers. By default it is not set.

## Contributing

I'm very open to new ideas, new features, anything really ;) . Open up an issue, send me a PR, or email.

TODO:
-----
- [ ] Improve behavior of jumps (invalid jumps?)
- [ ] Vim docs
- [ ] Fix behavior of `g:find_neoman_window` with tabs
