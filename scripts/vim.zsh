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
if [[ $SHELL == *'zsh' ]]; then
	compdef nman="man"
elif [[ $SHELL == *'bash' ]]; then
	complete -o default -o nospace -F _man nman
fi
