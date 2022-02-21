# shellcheck shell=bash

# @description Sets an error.
# @args $1 Error code
# @args $2 Error message
# @set number ERRCODE Error code
# @set string ERR Error message
core.err_set() {
	if (($# == 1)); then
		ERRCODE=1
		ERR=$1
	elif (($# == 2)); then
		ERRCODE=$1
		ERR=$2
	else
		printf '%s\n' "Error: bash-error: Incorrect function arguments"
		return 1
	fi

	if [ -z "$ERR" ]; then
		printf '%s\n' "Error: bash-error: Argument for 'ERR' cannot be empty"
		return 1
	fi
}

# @description Clears any of the global error state (sets to empty string).
# This means any `core.err_exists` calls after this _will_ return `true`
# @noargs
# @set number ERRCODE Error code
# @set string ERR Error message
core.err_clear() {
	ERRCODE=
	ERR=
}

# @description Checks if an error exists. If `ERR` is not empty, then an error
# _does_ exist
# @noargs
core.err_exists() {
	if [ -z "$ERR" ]; then
		return 1
	else
		return 0
	fi
}
