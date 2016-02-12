# neoman

Read manpages faster than superman!

![neoman in action](https://media.giphy.com/media/xT0BKrEeXPeKVMgb84/giphy.gif)

## Features
- Manpage autocompletion
- Open manpages whose section is not just a number
- Much more intuitive behavior than the builtin manpage plugin
- Open in a split/vsplit/tabe
- Open from inside a neovim terminal!
- Jump to manpages in specific sections through the manpage links

## Install
Any plugin manager should work fine.

```vim
Plug 'nhooyr/neoman.vim' "vim-plug
```

## Usage
### Command
The command is as follows:

```vim
Neoman[!] [{sect}] {page}[({sect})]
```

Several ways to use it, probably easier to explain with a few examples.

```vim
Neoman printf
Neoman 3 printf
Neoman printf(3)
```

Neoman without any arguments will use `<cword>` as the page.

See `g:neoman_current_window` under settings for an explaination of the bang.

## Mappings
`<c-]>` or `K` to jump to a manpage under the cursor.  
`<c-t>` to jump back.

You can also set the following in your `init.vim`/`.vimrc` and use `K` to jump to manpages globally for the word under the cursor.

```vim
set keywordprg=:Neoman
```

### Splits
Want to split/vsplit/tabe? Pretty simple.

```vim
:vsplit | Neoman! 3 printf
```

You can very easily make that a custom command or mapping.

### Command line integration

#### Neovim
You will need [nvr](https://github.com/mhinz/neovim-remote) for the super cool neovim terminal integration.

Add the following functions to your `.zshrc`/`.bashrc`

```zsh
_nman() {
	if [[ "$@" == "" ]]; then
		print "What manual page do you want?"
		return
	fi
	/usr/bin/man "$@" > /dev/null 2>&1
	if [[ "$?" != "0" ]]; then
		print "No manual entry for $*"
		return
	fi
	if [[ -z $NVIM_LISTEN_ADDRESS ]]; then
		/usr/bin/env nvim -c $cmd
	else
		nvr --remote-send "<c-n>" -c $cmd
	fi
}
nman() {
	cmd="Neoman $*"
	_nman "$@"
}
nman!() {
	cmd="Neoman! $*"
	_nman "$@"
}
```

#### Vim
```zsh
_nman() {
	if [[ "$@" == "" ]]; then
		print "What manual page do you want?"
		return
	fi
	/usr/bin/man "$@" > /dev/null 2>&1
	if [[ "$?" != "0" ]]; then
		print "No manual entry for $*"
		return
	fi
	vim -c $cmd
}
nman() {
	cmd="Neoman $*"
	_nman "$@"
}
nman!() {
	cmd="Neoman! $*"
	_nman "$@"
}
```

#### Autocomplete
##### zsh
```zsh
compdef nman="man"
compdef nman!="man"
```

##### bash
```bash
complete -o default -o nospace -F _man nman
complete -o default -o nospace -F _man nman!
```

Use `nman`/`nman!` to open the manpages. `nman!` works the same way as `:Neovim!`.

I've really only tested this with zsh, if you have any problems with bash and fix them please send a PR!

### Settings
`g:neoman_current_window`
If set, open the manpage in the current window, else attempt to find the currently open neoman window and use that. You can also use the bang on `:Neoman` to alternate between the two behaviors.

By default it is not set

TODO:
-----
- [ ] Vim docs
- [ ] More mappings
- [ ] Maybe history?
- [ ] Hijack `:Man` mode
