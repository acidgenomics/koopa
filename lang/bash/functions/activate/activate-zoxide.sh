#!/usr/bin/env bash

_koopa_activate_zoxide() {
    local zoxide
    zoxide="${KOOPA_PREFIX:?}/bin/zoxide"
    if [[ ! -x "$zoxide" ]]
    then
        return 0
    fi
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/zoxide-bash.sh"
    if [[ ! -f "$cache_file" ]] || [[ "$zoxide" -nt "$cache_file" ]]; then
        mkdir -p "${cache_file%/*}"
        "$zoxide" init bash > "$cache_file"
    fi
    source "$cache_file"
    unalias z 2>/dev/null || true
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
