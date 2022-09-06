#!/bin/sh

koopa_alias_kdev() {
    # """
    # Koopa 'kdev' shortcut alias.
    # @note Updated 2022-09-03.
    #
    # Alternative approach:
    # > export KOOPA_ACTIVATE=0
    # > "$bash" -il
    #
    # Potentially useful Bash options:
    # * --debugger
    # * --pretty-print
    # * --verbose
    # * -o option
    # * -O shopt_option
    #
    # @seealso
    # - https://superuser.com/questions/319043/
    # """
    local bash env
    bash="$(koopa_bin_prefix)/bash"
    env='/usr/bin/env'
    [ -x "$bash" ] || return 1
    [ -x "$env" ] || return 1
    "$env" -i \
        HOME="${HOME:?}" \
        KOOPA_ACTIVATE=0 \
        TERM_PROGRAM="${TERM_PROGRAM:-}" \
        "$bash" \
            -il \
            -o errexit \
            -o errtrace \
            -o nounset \
            -o pipefail
    return 0
}
