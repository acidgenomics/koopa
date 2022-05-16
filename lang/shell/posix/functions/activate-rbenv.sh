#!/bin/sh

koopa_activate_rbenv() {
    # """
    # Activate Ruby version manager (rbenv).
    # @note Updated 2022-05-12.
    #
    # See also:
    # - https://github.com/rbenv/rbenv
    # """
    local nounset prefix script
    [ -n "${RBENV_ROOT:-}" ] && return 0
    [ -x "$(koopa_bin_prefix)/rbenv" ] || return 0
    prefix="$(koopa_rbenv_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/rbenv"
    [ -r "$script" ] || return 0
    export RBENV_ROOT="$prefix"
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}
