#!/bin/sh
# shellcheck disable=SC2236

# Pre-flight checks.
# Modified 2019-06-18.



# Operating system                                                          {{{1
# ==============================================================================

# Bash sets the shell variable OSTYPE (e.g. linux-gnu).
# However, this doesn't work consistently with zsh, so use uname instead.

case "$(uname -s)" in
    Darwin)
        export MACOS=1
        export UNIX=1
        ;;
    Linux)
        export LINUX=1
        export UNIX=1
        ;;
    *)
        >&2 printf "Error: Unsupported operating system.\n"
        return 1
        ;;
esac



# Required programs                                                         {{{1
# ==============================================================================

assert_is_installed R
assert_is_installed Rscript
assert_is_installed bash
assert_is_installed cat
assert_is_installed chsh
assert_is_installed curl
assert_is_installed echo
assert_is_installed env
assert_is_installed grep
assert_is_installed python
assert_is_installed sed
assert_is_installed top
assert_is_installed wget
assert_is_installed which
