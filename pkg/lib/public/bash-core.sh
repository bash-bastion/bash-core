# shellcheck shell=bash

core.init() {
	# TODO: way below should error if any variables are not set

	if [ ${___global_bash_core_has_init__+x} ]; then
		return
	fi

	___global_bash_core_has_init__=
	declare -Ag ___global_trap_table___=()
	declare -ag ___global_shopt_stack___=()
}

# @description Get version of the package, from the point of the callsite. In other words, it
# returns the version of the package that has the file containing the direct caller of this
# function @set REPLY The full path to the directory
core.get_package_dir() {
	# local start_dir="${1:-"${BASH_SOURCE[1]}"}"

	# while [ ! -f 'basalt.toml' ] && [ "$PWD" != / ]; do
	# 	if ! cd ..; then
	# 		return 1
	# 	fi
	# done
	:
}

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
	signal_spec="${signal_spec#SIG}"
	if ! declare -f "$function" &>/dev/null; then
		printf '%s\n' "Error: core.trap_add: Function '$function' not defined" >&2
		return 1
	fi

	# start
	___global_trap_table___["$signal_spec"]="${___global_trap_table___[$signal_spec]}"$'\x1C'"$function"

	local global_trap_handler_name=
	printf -v global_trap_handler_name '%q' "___global_trap_${signal_spec}_handler___"

	if ! eval "$global_trap_handler_name() {
	core.trap_common_global_handler "$signal_spec"
}"; then
		printf '%s\n' "Error: core.trap_add: Could not eval function"
		return 1
	fi
	trap "$global_trap_handler_name" "$signal_spec"
}

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
}

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

# shellcheck disable=SC2120
core.shopt_pop() {
	# local repeat="$1"

	# TODO: wait until supporting it since on error, may be hard to ensure proper state of the stack
	# local regex='^[0-9]+$'
	# if [ -n "$repeat" ] && [[ "$repeat" =~ $regex ]]; then
	# 	for ((i=0; i<repeat; i++)); do
	# 		core.shopt_pop
	# 		return
	# 	done; unset i
	# fi; unset regex

	if (( ${#___global_shopt_stack___[@]} == 0 )); then
		printf '%s\n' "Error: core.shopt_pop: Unable to pop as nothing is in the shopt stack"
		return 1
	fi

	if (( ${#___global_shopt_stack___[@]} & 1 )); then
		printf '%s\n' "Fatal: core.shopt_pop: Shopt stack is malformed"
		return 1
	fi

	# Stack now guaranteed to have at least 2 elements
	local shopt_action="${___global_shopt_stack___[-2]}"
	local shopt_name="${___global_shopt_stack___[-1]}"

	if shopt -u "$shopt_name"; then :; else
		local errcode=$?
		printf '%s\n' "Fatal: core.shopt_pop: Could not restore previous option" >&2
		return $errcode
	fi

	___global_shopt_stack___=("${___global_shopt_stack___[@]::${#___global_shopt_stack___[@]}-2}")
}
