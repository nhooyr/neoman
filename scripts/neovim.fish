function _nman
	if [ (count $argv) -gt 3 ]
		echo "Too many arguments"
		return
	else if [ (count $argv) -eq 1 ]
		echo "What manual page do you want?"
		return
	end
	set page $argv[1..-2]
	set out (eval "command man -w $page 2>&1")
	set code $status
	if [ (count $out) -gt 1 -a (count $argv) -gt 2 ]
		echo "Too many manpages: $manpage_count"
		return
	else if [ $code != 0 ]
		printf '%s\n' $out
		return
	end
	if [ -z $NVIM_LISTEN_ADDRESS ]
		command nvim -c "$argv[-1] $page"
	else
		nvr --remote-send "<c-n>" -c "$argv[-1] $page"
	end
end
function nman
	_nman $argv 'Nman'
end
function nman!
	_nman $argv 'Nman!'
end
complete --command nman --wraps=man
complete --command nman! --wraps=man
