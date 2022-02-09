# shellcheck shell=bash

core.err_set() {
	if (($# == 1)); then
		ERRCODE=1
		ERR="$1"
	elif (($# == 2)); then
		ERRCODE="$1"
		ERR="$2"
	else
		printf '%s\n' "Error: bash-error: Incorrect function arguments"
		return 1
	fi

	if [ -z "$ERR" ]; then
		printf '%s\n' "Error: bash-error: Argument for 'ERR' cannot be empty"
		return 1
	fi
}

core.err_clear() {
	ERRCODE=
	ERR=
}

core.err_exists() {
	if [ -z "$ERR" ]; then
		return 1
	else
		return 0
	fi
}
