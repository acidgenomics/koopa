#!/bin/sh

koopa_alias_kdev() {
    # """
    # Koopa 'kdev' shortcut alias.
    # @note Updated 2022-09-06.
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
    if [ ! -x "$bash" ] && ! koopa_is_macos
    then
        bash='/usr/bin/bash'
    fi
    [ -x "$bash" ] || return 1
    env='/usr/bin/env'
    [ -x "$env" ] || return 1
    "$env" -i \
        HOME="${HOME:?}" \
        KOOPA_ACTIVATE=0 \
        SUDO_PS1="${SUDO_PS1:-}" \
        SUDO_USER="${SUDO_USER:-}" \
        TERM_PROGRAM="${TERM_PROGRAM:-}" \
        "$bash" \
            -il \
            -o errexit \
            -o errtrace \
            -o nounset \
            -o pipefail
    return 0
}
