#!/usr/bin/env bats

load './util/init.sh'

# Note that this and similar functions only test for array appending, not
# actual execution of the functions on the signal. There seems to be a limitation
# of Bats that prevents this from working

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
	core.trap_add 'somefunction' 'USR1'

	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction' ]
}

@test "core.trap_add adds function properly 2" {
	somefunction() { :; }
	somefunction2() { :; }
	core.trap_add 'somefunction' 'USR1'
	core.trap_add 'somefunction2' 'USR1'

	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction\x1Csomefunction2' ]
}

@test "core.trap_remove removes trap function properly 1" {
	somefunction() { :; }
	core.trap_add 'somefunction' 'USR1'
	core.trap_remove 'somefunction' 'USR1'

	[ "${___global_trap_table___[USR1]}" = '' ]
}

@test "core.trap_remove removes trap function properly 2" {
	somefunction() { :; }
	somefunction2() { :; }
	core.trap_add 'somefunction' 'USR1'
	core.trap_add 'somefunction2' 'USR1'
	core.trap_remove 'somefunction' 'USR1'

	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction2' ]
}

@test "core.trap_remove removes trap function properly 3" {
	somefunction() { :; }
	somefunction2() { :; }
	core.trap_add 'somefunction' 'USR1'
	core.trap_add 'somefunction2' 'USR1'
	core.trap_remove 'somefunction2' 'USR1'

	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction' ]
}
