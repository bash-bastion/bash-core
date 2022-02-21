# shellcheck shell=bash

task.test() {
	bats tests
}

task.docs() {
	shdoc < './pkg/lib/public/bash-core.sh' > './docs/api.md'
}
