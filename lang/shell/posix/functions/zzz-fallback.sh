#!/bin/sh

# FIXME NUKE THESE IN OUR CODE...

if ! _koopa_is_installed basename
then
    basename() { # {{{1
        _koopa_basename "$@"
    }
fi

if ! _koopa_is_installed echo
then
    echo() { # {{{1
        _koopa_print "$@"
    }
fi
