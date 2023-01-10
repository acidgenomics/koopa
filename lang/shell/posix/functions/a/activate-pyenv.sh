#!/bin/sh

koopa_activate_pyenv() {
    # """
    # Activate Python version manager (pyenv).
    # @note Updated 2022-05-12.
    #
    # Note that pyenv forks rbenv, so activation is very similar.
    # """
    local nounset prefix script
    [ -n "${PYENV_ROOT:-}" ] && return 0
    [ -x "$(koopa_bin_prefix)/pyenv" ] || return 0
    prefix="$(koopa_pyenv_prefix)"
    [ -d "$prefix" ] || return 0
    script="${prefix}/bin/pyenv"
    [ -r "$script" ] || return 0
    export PYENV_ROOT="$prefix"
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$("$script" init -)"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}
