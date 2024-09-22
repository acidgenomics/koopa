#!/bin/sh

_koopa_alias_kdev() {
    # """
    # Koopa 'kdev' shortcut alias.
    # @note Updated 2024-09-18.
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
    if [ ! -x "$__kvar_bash" ]
    then
        if _koopa_is_linux
        then
            __kvar_bash='/bin/bash'
        elif _koopa_is_macos
        then
            __kvar_bash="$(_koopa_bootstrap_prefix)/bin/bash"
        fi
    fi
    if [ ! -x "$__kvar_bash" ]
    then
        __koopa_print 'Failed to locate bash.'
        return 1
    fi
    if [ ! -x "$__kvar_env" ]
    then
        __kvar_env='/usr/bin/env'
    fi
    if [ ! -x "$__kvar_env" ]
    then
        __koopa_print 'Failed to locate env.'
        return 1
    fi
    __kvar_rcfile="${__kvar_koopa_prefix}/lang/bash/include/header.sh"
    [ -f "$__kvar_rcfile" ] || return 1
    # > PATH='/usr/bin:/bin'
    "$__kvar_env" -i \
        AWS_CLOUDFRONT_DISTRIBUTION_ID="${AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" \
        HOME="${HOME:?}" \
        HTTP_PROXY="${HTTP_PROXY:-}" \
        HTTPS_PROXY="${HTTPS_PROXY:-}" \
        KOOPA_ACTIVATE=0 \
        KOOPA_BUILDER="${KOOPA_BUILDER:-0}" \
        KOOPA_CAN_INSTALL_BINARY="${KOOPA_CAN_INSTALL_BINARY:-}" \
        LANG='C' \
        LC_ALL='C' \
        PATH="${PATH:?}" \
        SUDO_PS1="${SUDO_PS1:-}" \
        SUDO_USER="${SUDO_USER:-}" \
        TMPDIR="${TMPDIR:-/tmp}" \
        http_proxy="${http_proxy:-}" \
        https_proxy="${https_proxy:-}" \
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
