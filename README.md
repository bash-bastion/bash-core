# bash-core

Useful functions for any Bash program. Often vital for Basalt programs

## Summary

### `init`

- `core.init`

Initialize global variables used by other functions

Add and remove traps. With these, multiple packages can add or remove traps handlers for signals

### `trap`

- `core.trap_add`
- `core.trap_remove`

Example

```sh
some_handler() { printf '%s\n' 'This was called on USR1! ^w^'; }
core.trap_add 'some_handler' 'USR1'
kill -USR1 $$
core.trap_remove 'some_handler' 'USR1'
```

### `shopt`

- `core.shopt_push`
- `core.shopt_pop`

Example

```sh
core.shopt_push -s extglob
[[ 'variable' == @(foxtrot|golf|echo|variable) ]] && printf '%s\n' 'Woof!'
core.shopt_pop
```

### `err`

I suppose it can look redundant (compared to `if ! fn; then :; fi`), but it can help make errors a bit more safe in larger applications, since you don't have to worry about a caller forgetting to `if ! fn` or `fn ||` (and terminating the script if `set -e`). It also makes it easier to communicate specific error codes and helps separate between calculated / expected errors and unexpected errors (fatal / faults)

- `core.err_set`
- `core.err_clear`
- `core.err_exists`

Example

```sh
create_some_error() { core.err_clear; core.err_set 'Some error' }

create_some_error || fatal "Did not expect an error"
if core.err_exists; then
  printf '%s\n' 'Something happened'
fi
```

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to add this project as a dependency

```sh
basalt add hyperupcall/bash-core
```
