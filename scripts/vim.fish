function nman
	if [ (count $argv) -gt 2 ]
		echo "Too many arguments"
		return
	else if [ (count $argv) -eq 0 ]
		echo "What manual page do you want?"
		return
	end
	set out (eval "command man -w $argv 2>&1")
	set code $status
	if [ (count $out) -gt 1 -a (count $argv) -gt 1 ]
		echo "Too many manpages: $manpage_count"
		return
	else if [ $code != 0 ]
		printf '%s\n' $out
		return
	end
	vim -c "Nman $argv"
end
complete --command nman --wraps=man
