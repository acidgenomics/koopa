#!/bin/sh

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

if ! _koopa_is_installed realpath
then
    realpath() { # {{{1
        _koopa_realpath "$@"
    }
fi
