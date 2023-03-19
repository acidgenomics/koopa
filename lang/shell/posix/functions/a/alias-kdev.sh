#!/bin/sh

_koopa_alias_kdev() {
    # """
    # Koopa 'kdev' shortcut alias.
    # @note Updated 2023-03-11.
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
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    __kvar_koopa_prefix="$(_koopa_koopa_prefix)"
    __kvar_bash="${__kvar_bin_prefix}/bash"
    __kvar_env="${__kvar_bin_prefix}/genv"
    __kvar_rcfile="${__kvar_koopa_prefix}/lang/shell/bash/include/header.sh"
    [ -x "$__kvar_bash" ] || return 1
    [ -x "$__kvar_env" ] || return 1
    [ -f "$__kvar_rcfile" ] || return 1
    "$__kvar_env" -i \
        HOME="${HOME:?}" \
        KOOPA_ACTIVATE=0 \
        PATH='/usr/bin:/bin' \
        SUDO_PS1="${SUDO_PS1:-}" \
        SUDO_USER="${SUDO_USER:-}" \
        TMPDIR="${TMPDIR:-/tmp}" \
        "$__kvar_bash" \
            --noprofile \
            --rcfile "$__kvar_rcfile" \
            -o errexit \
            -o errtrace \
            -o nounset \
            -o pipefail
    unset -v \
        __kvar_bash \
        __kvar_bin_prefix \
        __kvar_env \
        __kvar_koopa_prefix \
        __kvar_rcfile
    return 0
}
