#!/bin/sh
# shellcheck disable=SC2039

if ! _koopa_is_installed basename
then
    basename() {  # {{{1
        _koopa_basename "$@"
    }
fi

if ! _koopa_is_installed realpath
then
    realpath() {  # {{{1
        _koopa_realpath "$@"
    }
fi
