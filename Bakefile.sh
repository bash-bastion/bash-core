# shellcheck shell=bash

task.test() {
	bats tests
}

task.docs() {
	shdoc > './docs/api.md' < <(
		for f in ./pkg/lib/public/*.sh; do
			cat "$f"
		done
	)
}
