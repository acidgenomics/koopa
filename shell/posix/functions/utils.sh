#!/bin/sh
# shellcheck disable=SC2039

_koopa_array_to_r_vector() {                                              # {{{3
    # """
    # Convert a bash array to an R vector string.
    # Updated 2019-09-25.
    #
    # Example: ("aaa" "bbb") array to 'c("aaa", "bbb")'.
    # """
    local x
    x="$(printf '"%s", ' "$@")"
    x="$(_koopa_strip_right "$x" ", ")"
    printf "c(%s)\n" "$x"
}

_koopa_quiet_cd() {                                                       # {{{3
    # """
    # Change directory quietly
    # Updated 2019-10-29.
    # """
    cd "$@" > /dev/null || return 1
}

_koopa_quiet_expr() {                                                     # {{{3
    # """
    # Quiet regular expression matching that is POSIX compliant.
    # Updated 2019-10-08.
    #
    # Avoid using '[[ =~ ]]' in sh config files.
    # 'expr' is faster than using 'case'.
    #
    # See also:
    # - https://stackoverflow.com/questions/21115121
    # """
    expr "$1" : "$2" 1>/dev/null
}

_koopa_quiet_rm() {                                                       # {{{3
    # """
    # Remove quietly.
    # Updated 2019-10-29.
    # """
    rm -fr "$@" > /dev/null 2>&1
}
