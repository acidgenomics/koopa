#!/bin/sh

# Quiet variants
# Modified 2019-06-20.



_koopa_quiet_cd() {
    cd "$@" >/dev/null || return 1
}



# Regular expression matching that is POSIX compliant.
# https://stackoverflow.com/questions/21115121
# Avoid using `[[ =~ ]]` in sh config files.
# `expr` is faster than using `case`.
_koopa_quiet_expr() {
    expr "$1" : "$2" 1>/dev/null
}



# Consider not using `&>` here, it isn't POSIX.
# https://unix.stackexchange.com/a/80632
# > command -v "$1" >/dev/null
_koopa_quiet_which() {
    command -v "$1" >/dev/null 2>&1
}

