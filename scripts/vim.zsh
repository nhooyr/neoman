function nman {
	if (( $# > 2 )); then
		echo "Too many arguements"
		return
	elif [[ $# == 0 ]]; then
		echo "What manual page do you want?"
		return
	fi
	local tmp=$IFS
	IFS=$'\n' out=($(command man -w $* 2>&1))
	local code=$?
	IFS=$tmp
	if [[ ${#out[@]} > 1 ]] && (( $# > 1 )); then
		echo "Too many manpages: ${#out[@]}"
		return
	elif [[ $code != 0 ]]; then
		printf '%s\n' "${out[@]}"
		return
	fi
	vim -c "Nman $*"
}
if [[ $0 == *'zsh' ]]; then
	compdef nman="man"
elif [[ $0 == *'bash' && $(complete) == *'_man'* ]]; then
	complete -o default -o nospace -F _man nman
fi
