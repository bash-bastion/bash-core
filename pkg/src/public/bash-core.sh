# shellcheck shell=bash

# @name bash-core
# @description Core functions for any Bash program

# @description Initiates global variables used by other functions
# @noargs
core.init() {
	# TODO: way below should error if any variables are not set

	if [ ${___global_bash_core_has_init__+x} ]; then
		return
	fi

	___global_bash_core_has_init__=
	declare -Ag ___global_trap_table___=()
	declare -ag ___global_shopt_stack___=()
}

# @description Adds a handler for a particular `trap` signal or event. Noticably,
# unlike the 'builtin' trap, this does not override any other existing handlers
# @arg $1 string Function to execute on an event. Integers are forbiden
# @arg $2 string Event signal
# @example
#   some_handler() { printf '%s\n' 'This was called on USR1! ^w^'; }
#   core.trap_add 'some_handler' 'USR1'
#   kill -USR1 $$
#   core.trap_remove 'some_handler' 'USR1'
core.trap_add() {
	local function="$1"
	local signal_spec="$2"

	# validation
	if [ -z "$function" ]; then
		printf '%s\n' "Error: core.trap_add: First argument cannot be empty"
		return 1
	fi
	if [ -z "$signal_spec" ]; then
		printf '%s\n' "Error: core.trap_add: Second argument cannot be empty"
		return 1
	fi
	local regex='^[0-9]+$'
	if [[ "$signal_spec" =~ $regex ]]; then
		printf '%s\n' "Error: core.trap_add: Passing numbers for the signal specs is prohibited"
		return 1
	fi; unset regex
	signal_spec=${signal_spec#SIG}
	if ! declare -f "$function" &>/dev/null; then
		printf '%s\n' "Error: core.trap_add: Function '$function' not defined" >&2
		return 1
	fi

	# start
	___global_trap_table___["$signal_spec"]="${___global_trap_table___[$signal_spec]}"$'\x1C'"$function"

	# rho (WET)
	local global_trap_handler_name=
	printf -v global_trap_handler_name '%q' "core.trap_handler_${signal_spec}"

	if ! eval "$global_trap_handler_name() {
	core.trap_handler_common '$signal_spec'
}"; then
		printf '%s\n' "Error: core.trap_add: Could not eval function"
		return 1
	fi
	# shellcheck disable=SC2064
	trap "$global_trap_handler_name" "$signal_spec"
}

# @description Removes a handler for a particular `trap` signal or event. Currently,
# if the function doest not exist, it prints an error
# @arg $1 string Function to remove
# @arg $2 string Signal that the function executed on
# @example
#   some_handler() { printf '%s\n' 'This was called on USR1! ^w^'; }
#   core.trap_add 'some_handler' 'USR1'
#   kill -USR1 $$
#   core.trap_remove 'some_handler' 'USR1'
core.trap_remove() {
	local function="$1"
	local signal_spec="$2"

	# validation
	if [ -z "$function" ]; then
		printf '%s\n' "Error: core.trap_add: First argument cannot be empty"
		return 1
	fi
	if [ -z "$signal_spec" ]; then
		printf '%s\n' "Error: core.trap_add: Second argument cannot be empty"
		return 1
	fi
	local regex='^[0-9]+$'
	if [[ "$signal_spec" =~ $regex ]]; then
		printf '%s\n' "Error: core.trap_add: Passing numbers for the signal specs is prohibited"
		return 1
	fi; unset regex
	signal_spec="${signal_spec#SIG}"
	if ! declare -f "$function" &>/dev/null; then
		printf '%s\n' "Error: core.trap_add: Function '$function' not defined" >&2
		return 1
	fi

	# start
	local -a trap_handlers=()
	local new_trap_handlers=
	IFS=$'\x1C' read -ra trap_handlers <<< "${___global_trap_table___[$signal_spec]}"
	for trap_handler in "${trap_handlers[@]}"; do
		if [ -z "$trap_handler" ] || [ "$trap_handler" = $'\x1C' ]; then
			continue
		fi

		if [ "$trap_handler" = "$function" ]; then
			continue
		fi

		new_trap_handlers+=$'\x1C'"$trap_handler"
	done; unset trap_handler

	___global_trap_table___["$signal_spec"]="$new_trap_handlers"

	# rho (WET)
	local global_trap_handler_name=
	printf -v global_trap_handler_name '%q' "___global_trap_${signal_spec}_handler___"
	unset -f "$global_trap_handler_name"
}

# @description Modifies current shell options and pushes information to stack, so
# it can later be easily undone. Note that it does not check to see if your Bash
# version supports the
# @arg $1 string Name of shopt action. Can either be `-u` or `-s`
# @arg $2 string Name of shopt name
# @example
#   core.shopt_push -s extglob
#   [[ 'variable' == @(foxtrot|golf|echo|variable) ]] && printf '%s\n' 'Woof!'
#   core.shopt_pop
core.shopt_push() {
	local shopt_action="$1"
	local shopt_name="$2"

	if [ -z "$shopt_action" ]; then
		printf '%s\n' "Error: core.shopt_push: First argument cannot be empty"
		return 1
	fi

	if [ -z "$shopt_name" ]; then
		printf '%s\n' "Error: core.shopt_push: Second argument cannot be empty"
		return 1
	fi

	local -i previous_shopt_errcode=
	if shopt -q "$shopt_name"; then
		previous_shopt_errcode=$?
	else
		previous_shopt_errcode=$?
	fi

	if [ "$shopt_action" = '-s' ]; then
		if shopt -s "$shopt_name"; then :; else
			# on error, option will not be set
			return $?
		fi
	elif [ "$shopt_action" = '-u' ]; then
		if shopt -u "$shopt_name"; then :; else
			# on error, option will not be set
			return $?
		fi
	else
		printf '%s\n' "Error: core.shopt_push: Accepted actions are either '-s' or '-u'" >&2
		return 1
	fi

	if (( previous_shopt_errcode == 0)); then
		___global_shopt_stack___+=(-s "$shopt_name")
	else
		___global_shopt_stack___+=(-u "$shopt_name")
	fi
}

# @description Modifies current shell options based on most recent item added to stack.
# @noargs
# @example
#   core.shopt_push -s extglob
#   [[ 'variable' == @(foxtrot|golf|echo|variable) ]] && printf '%s\n' 'Woof!'
#   core.shopt_pop
core.shopt_pop() {
	if (( ${#___global_shopt_stack___[@]} == 0 )); then
		printf '%s\n' "Error: core.shopt_pop: Unable to pop as nothing is in the shopt stack"
		return 1
	fi

	if (( ${#___global_shopt_stack___[@]} & 1 )); then
		printf '%s\n' "Fatal: core.shopt_pop: Shopt stack is malformed"
		return 1
	fi

	# Stack now guaranteed to have at least 2 elements (so the following accessors won't error)
	local shopt_action="${___global_shopt_stack___[-2]}"
	local shopt_name="${___global_shopt_stack___[-1]}"

	if shopt -u "$shopt_name"; then :; else
		local errcode=$?
		printf '%s\n' "Fatal: core.shopt_pop: Could not restore previous option" >&2
		return $errcode
	fi

	___global_shopt_stack___=("${___global_shopt_stack___[@]::${#___global_shopt_stack___[@]}-2}")
}

# @description Sets an error.
# @arg $1 Error code
# @arg $2 Error message
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

# @description Prints stacktrace
# @noargs
# @example
#  err_handler() {
#    local exit_code=$?
#    core.stacktrace_print
#    exit $exit_code
#  }
#  core.trap_add 'err_handler' ERR
core.stacktrace_print() {
	printf '%s\n' 'Stacktrace:'

	local i=
	for ((i=0; i<${#FUNCNAME[@]}-1; ++i)); do
		printf '%s\n' "  in ${FUNCNAME[$i]} (${BASH_SOURCE[$i]}:${BASH_LINENO[$i-1]})"
	done; unset -v i
} >&2

# @description Determine if color should be printed
# @internal
core.should_color_output() {
	# TODO: 'COLORTERM'

	# https://no-color.org
	if [[ -v NO_COLOR ]]; then
		return 1
	fi

	# 0 => 2 colors
	# 1 => 16 colors
	# 2 => 256 colors
	# 3 => 16,777,216 colors
	if [[ -v FORCE_COLOR ]]; then
		return 0
	fi

	if [[ $TERM == dumb ]]; then
		return 0
	fi
}

# @description Get version of the package, from the point of the callsite. In other words, it
# returns the version of the package that has the file containing the direct caller of this
# @set REPLY The full path to the directory
# @internal
core.get_package_dir() {
	# local start_dir="${1:-"${BASH_SOURCE[1]}"}"

	# while [ ! -f 'basalt.toml' ] && [ "$PWD" != / ]; do
	# 	if ! cd ..; then
	# 		return 1
	# 	fi
	# done
	:
}
