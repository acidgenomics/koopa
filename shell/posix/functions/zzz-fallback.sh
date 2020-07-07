#!/bin/sh

if ! _koopa_is_installed basename
then
    basename() {
        _koopa_basename "$@"
    }
fi

if ! _koopa_is_installed echo
then
    echo() {
        _koopa_print "$@"
    }
fi

if ! _koopa_is_installed realpath
then
    realpath() {
        _koopa_realpath "$@"
    }
fi
