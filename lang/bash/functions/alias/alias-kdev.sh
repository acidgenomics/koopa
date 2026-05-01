#!/usr/bin/env bash

_koopa_alias_kdev() {
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    local _koopa_prefix
    _koopa_prefix="$(_koopa_koopa_prefix)"
    local bash
    bash="${bin_prefix}/bash"
    local env
    env="${bin_prefix}/genv"
    if [[ ! -x "$bash" ]]
    then
        if _koopa_is_linux
        then
            bash='/bin/bash'
        elif _koopa_is_macos
        then
            bash="$(_koopa_bootstrap_prefix)/bin/bash"
        fi
    fi
    if [[ ! -x "$bash" ]]
    then
        _koopa_print 'Failed to locate bash.'
        return 1
    fi
    if [[ ! -x "$env" ]]
    then
        env='/usr/bin/env'
    fi
    if [[ ! -x "$env" ]]
    then
        _koopa_print 'Failed to locate env.'
        return 1
    fi
    local rcfile
    rcfile="${_koopa_prefix}/lang/bash/include/header.sh"
    [[ -f "$rcfile" ]] || return 1
    "$env" -i \
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
        "$bash" \
            --noprofile \
            --rcfile "$rcfile" \
            -o errexit \
            -o errtrace \
            -o nounset \
            -o pipefail
    return 0
}
