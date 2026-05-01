#!/usr/bin/env bash

_koopa_activate_asdf() {
    local prefix
    prefix="${1:-}"
    if [[ -z "$prefix" ]]
    then
        prefix="$(_koopa_asdf_prefix)"
    fi
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local script
    script="${prefix}/libexec/asdf.sh"
    if [[ ! -r "$script" ]]
    then
        return 0
    fi
    _koopa_is_alias 'asdf' && unalias 'asdf'
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    source "$script"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
