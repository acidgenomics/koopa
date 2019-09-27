#!/bin/sh

# Pre-flight checks.
# Updated 2019-09-24.



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

_koopa_assert_is_installed basename bash cat chsh curl dirname echo env grep   \
    head less man nice parallel realpath sed sh tail tee top wget which
