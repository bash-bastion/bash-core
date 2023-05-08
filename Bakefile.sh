# shellcheck shell=bash

task.init() {
	hookah refresh
}

task.test() {
	bats tests
}

task.lint() {
	shellcheck ./pkg/**/*.sh
}

task.docs() {
	shdoc < './pkg/src/public/bash-core.sh' > './docs/api.md'
}
