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
        ;;
    Linux)
        ;;
    *)
        >&2 printf "Error: Unsupported operating system.\n"
        return 1
        ;;
esac



# Required programs                                                         {{{1
# ==============================================================================

_koopa_assert_is_installed R
_koopa_assert_is_installed Rscript
_koopa_assert_is_installed bash
_koopa_assert_is_installed cat
_koopa_assert_is_installed chsh
_koopa_assert_is_installed curl
_koopa_assert_is_installed echo
_koopa_assert_is_installed env
_koopa_assert_is_installed grep
_koopa_assert_is_installed python
_koopa_assert_is_installed sed
_koopa_assert_is_installed top
_koopa_assert_is_installed wget
_koopa_assert_is_installed which
