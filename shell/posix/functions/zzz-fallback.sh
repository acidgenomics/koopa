#!/bin/sh
# shellcheck disable=SC2039

if ! koopa::is_installed basename
then
    basename() { # {{{1
        koopa::basename "$@"
    }
fi

if ! koopa::is_installed realpath
then
    realpath() { # {{{1
        koopa::realpath "$@"
    }
fi
