#!/bin/sh
# shellcheck disable=SC2039

# Readline. Currently uses emacs by default.
# https://unix.stackexchange.com/questions/30454
# > case "$EDITOR" in
# >     emacs)
# >         set -o emacs
# >         ;;
# >     vi|vim)
# >         set -o vi
# >         ;;
# > esac
