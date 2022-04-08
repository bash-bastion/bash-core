#!/usr/bin/env bats

load './util/init.sh'

# Note that this and similar functions only test for array appending, not
# actual execution of the functions on the signal. There seems to be a limitation
# of Bats that prevents this from working

# The '${___global_trap_table___[nokey]}' is there to ensure that the
# ___global_trap_table___ is an actual associative array. If '___global_trap_table___' is not an associative array, the index with 'nokey' still returns the value of the variable (no error will be thrown). These were origianlly done when the 'core.init' function was not called within these tests

@test "core.trap_add fails when function specified does not exist" {
	run core.trap_add 'nonexistent' 'USR1'

	assert_failure
	assert_output -p "Function 'nonexistent' is not defined"
}

@test "core.trap_add fails when number is given for signal" {
	run core.trap_add 'function' '0'

	assert_failure
	assert_output -p "Passing numbers for the signal specs is prohibited"
}

@test "core.trap_add adds trap function properly" {
	somefunction() { :; }
	core.init
	core.trap_add 'somefunction' 'USR1'

	[ "${___global_trap_table___[nokey]}" != $'\x1Csomefunction' ]
	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction' ]
}

@test "core.trap_add adds function properly 2" {
	somefunction() { :; }
	somefunction2() { :; }
	core.init
	core.trap_add 'somefunction' 'USR1'
	core.trap_add 'somefunction2' 'USR1'

	[ "${___global_trap_table___[nokey]}" != $'\x1Csomefunction\x1Csomefunction2' ]
	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction\x1Csomefunction2' ]
}

@test "core.trap_remove fails when function specified does not exist" {
	run core.trap_remove 'nonexistent' 'USR1'

	assert_failure
	assert_output -p "Function 'nonexistent' is not defined"
}

@test "core.trap_remove removes trap function properly 1" {
	somefunction() { :; }
	core.init
	core.trap_add 'somefunction' 'USR1'
	core.trap_remove 'somefunction' 'USR1'

	[ "${___global_trap_table___[USR1]}" = '' ]
}

@test "core.trap_remove removes trap function properly 2" {
	somefunction() { :; }
	somefunction2() { :; }
	core.init
	core.trap_add 'somefunction' 'USR1'
	core.trap_add 'somefunction2' 'USR1'
	core.trap_remove 'somefunction' 'USR1'

	[ "${___global_trap_table___[nokey]}" != $'\x1Csomefunction2' ]
	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction2' ]
}

@test "core.trap_remove removes trap function properly 3" {
	somefunction() { :; }
	somefunction2() { :; }
	core.init
	core.trap_add 'somefunction' 'USR1'
	core.trap_add 'somefunction2' 'USR1'
	core.trap_remove 'somefunction2' 'USR1'

	[ "${___global_trap_table___[nokey]}" != $'\x1Csomefunction' ]
	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction' ]
}
