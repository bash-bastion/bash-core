# shellcheck shell=bash

# @description Prints stacktrace
core.stacktrace_print() {
	printf '%s\n' 'Stacktrace:'

	local i=
	for ((i=0; i<${#FUNCNAME[@]}-1; ++i)); do
		printf '%s\n' "  in ${FUNCNAME[$i]} (${BASH_SOURCE[$i]}:${BASH_LINENO[$i-1]})"
	done; unset -v i
} >&2
