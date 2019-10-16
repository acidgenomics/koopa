#!/bin/sh

# Pre-flight checks.
# Updated 2019-10-16.



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



# Bad settings                                                              {{{1
# ==============================================================================

_koopa_warn_if_export "JAVA_HOME" "LD_LIBRARY_PATH" "PYTHONHOME" "R_HOME"
