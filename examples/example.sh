#!/usr/bin/env bash

set -eo pipefail
shopt -s dotglob globstar nullglob

for f in ../pkg/**/*.sh; do
	source "$f"
done; unset f

fn1() {
	printf '%s\n' 'Function 1 called'
}

fn2() {
	printf '%s\n' 'Function 2 called'
}

core.trap_add 'fn1' SIGINT
core.trap_add 'fn2' SIGINT
core.trap_remove 'fn2' SIGINT

read -r
