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
complete --command nman --wraps=man
complete --command nman! --wraps=man
