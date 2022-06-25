# shellcheck shell=bash

# @internal
core.private.util.init() {
	if [ ${___global_bash_core_has_init__+x} ]; then
		return
	fi

	___global_bash_core_has_init__=
	declare -gA ___global_trap_table___=()
	declare -ga ___global_shopt_stack___=()
}

# @internal
core.private.util.trap_handler_common() {
	local signal_spec="$1"

	local trap_handlers=
	IFS=$'\x1C' read -ra trap_handlers <<< "${___global_trap_table___[$signal_spec]}"

	local trap_handler=
	for trap_handler in "${trap_handlers[@]}"; do
		if [ -z "$trap_handler" ]; then
			continue
		fi

		if declare -f "$trap_handler" &>/dev/null; then
			"$trap_handler"
		else
			printf "%s\n" "Warn: core.trap_add: Function '$trap_handler' registered for signal '$signal_spec' no longer exists. Skipping" >&2
		fi
	done; unset trap_func
}

# @description Prints the current error stored
# @internal
core.private.util.err_print() {
	printf '%s\n' 'Error found:'
	printf '%s\n' "  ERRCODE: $ERRCODE" >&2
	printf '%s\n' "  ERR: $ERR" >&2
}

# @description Determine if should print color, given a file descriptor
# @arg 1 File descriptor for terminal check
# @internal
core.private.should_print_color() {
	local fd="$1"

	if [[ ${NO_COLOR+x} || "$TERM" = 'dumb' ]]; then
		return 1
	fi

	if [ -t "$fd" ]; then
		return 0
	fi

	return 1
}