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
complete --command nman --wraps=man
