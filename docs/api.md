# bash-core

## Overview

Core functions for any Bash program

## Index

* [core.init()](#coreinit)
* [core.trap_add()](#coretrap_add)
* [core.trap_remove()](#coretrap_remove)
* [core.shopt_push()](#coreshopt_push)
* [core.shopt_pop()](#coreshopt_pop)
* [core.err_set()](#coreerr_set)
* [core.err_clear()](#coreerr_clear)
* [core.err_exists()](#coreerr_exists)
* [core.stacktrace_print()](#corestacktrace_print)

### core.init()

Initiates global variables used by other functions

_Function has no arguments._

### core.trap_add()

Adds a handler for a particular `trap` signal or event. Noticably,
unlike the 'builtin' trap, this does not override any other existing handlers

#### Example

```bash
some_handler() { printf '%s\n' 'This was called on USR1! ^w^'; }
core.trap_add 'some_handler' 'USR1'
kill -USR1 $$
core.trap_remove 'some_handler' 'USR1'
```

#### Arguments

* **$1** (string): Function to execute on an event. Integers are forbiden
* **$2** (string): Event signal

### core.trap_remove()

Removes a handler for a particular `trap` signal or event. Currently,
if the function doest not exist, it prints an error

#### Example

```bash
some_handler() { printf '%s\n' 'This was called on USR1! ^w^'; }
core.trap_add 'some_handler' 'USR1'
kill -USR1 $$
core.trap_remove 'some_handler' 'USR1'
```

#### Arguments

* **$1** (string): Function to remove
* **$2** (string): Signal that the function executed on

### core.shopt_push()

Modifies current shell options and pushes information to stack, so
it can later be easily undone. Note that it does not check to see if your Bash
version supports the

#### Example

```bash
core.shopt_push -s extglob
[[ 'variable' == @(foxtrot|golf|echo|variable) ]] && printf '%s\n' 'Woof!'
core.shopt_pop
```

#### Arguments

* **$1** (string): Name of shopt action. Can either be `-u` or `-s`
* **$2** (string): Name of shopt name

### core.shopt_pop()

Modifies current shell options based on most recent item added to stack.

#### Example

```bash
core.shopt_push -s extglob
[[ 'variable' == @(foxtrot|golf|echo|variable) ]] && printf '%s\n' 'Woof!'
core.shopt_pop
```

_Function has no arguments._

### core.err_set()

Sets an error.

#### Arguments

* **$1** (Error): code
* **$2** (Error): message

#### Variables set

* **number** (ERRCODE): Error code
* **string** (ERR): Error message

### core.err_clear()

Clears any of the global error state (sets to empty string).
This means any `core.err_exists` calls after this _will_ return `true`

_Function has no arguments._

#### Variables set

* **number** (ERRCODE): Error code
* **string** (ERR): Error message

### core.err_exists()

Checks if an error exists. If `ERR` is not empty, then an error
_does_ exist

_Function has no arguments._

### core.stacktrace_print()

Prints stacktrace

#### Example

```bash
core.trap_add 'err_handler' EXIT
err_handler() {
  local exit_code=$?
  core.stacktrace_print
  exit $?
}
```

_Function has no arguments._
