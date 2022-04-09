# bash-core

Core functions for any Bash program

## Summary

The following are functions available for use. See [api.md](./docs/api.md) for more details

### `init`

- `core.util.init`

Initialize global variables used by other functions

Add and remove traps. With these, multiple packages can add or remove traps handlers for signals

### `trap`

- `core.trap_add`
- `core.trap_remove`

### `shopt`

- `core.shopt_push`
- `core.shopt_pop`

### `err`

I suppose it can look redundant (compared to `if ! fn; then :; fi`), but it can help make errors a bit more safe in larger applications, since you don't have to worry about a caller forgetting to `if ! fn` or `fn ||` (and terminating the script if `set -e`). It also makes it easier to communicate specific error codes and helps separate between calculated / expected errors and unexpected errors (fatal / faults)

- `core.err_set`
- `core.err_clear`
- `core.err_exists`

### `stacktrace`

Prints the stack trace. Recommended to use with `core.trap_add`

- `core.stacktrace_print`

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to add this project as a dependency

```sh
basalt add hyperupcall/bash-core
```
