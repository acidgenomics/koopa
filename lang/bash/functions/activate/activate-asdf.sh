#!/usr/bin/env bash

_koopa_activate_asdf() {
    local prefix
    prefix="${1:-}"
    if [[ -z "$prefix" ]]
    then
        prefix="${KOOPA_PREFIX:?}/opt/asdf"
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
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    source "$script"
    unalias asdf 2>/dev/null || true
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
