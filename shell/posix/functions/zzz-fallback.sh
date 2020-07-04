#!/bin/sh
# shellcheck disable=SC2039

if ! koopa::is_installed basename
then
    basename() {
        koopa::basename "$@"
    }
fi

if ! koopa::is_installed echo
then
    echo() {
        koopa::print "$@"
    }
fi

if ! koopa::is_installed print
then
    print() {
        koopa::print "$@"
    }
fi

if ! koopa::is_installed realpath
then
    realpath() {
        koopa::realpath "$@"
    }
fi
