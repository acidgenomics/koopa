#!/usr/bin/env bash

_koopa_activate_mise() {
    local mise
    mise="${KOOPA_PREFIX:?}/bin/mise"
    if [[ ! -x "$mise" ]]
    then
        return 0
    fi
    local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/mise-bash.sh"
    if [[ ! -f "$cache_file" ]] || [[ "$mise" -nt "$cache_file" ]]; then
        mkdir -p "${cache_file%/*}"
        "$mise" activate bash > "$cache_file"
    fi
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    source "$cache_file"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
