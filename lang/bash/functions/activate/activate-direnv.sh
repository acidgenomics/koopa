#!/usr/bin/env bash

_koopa_activate_direnv() {
    local direnv
    direnv="${KOOPA_PREFIX:?}/bin/direnv"
    if [[ ! -x "$direnv" ]]
    then
        return 0
    fi
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    unset -v \
        DIRENV_DIFF \
        DIRENV_DIR \
        DIRENV_FILE \
        DIRENV_WATCHES
    local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/direnv-hook-bash.sh"
    if [[ ! -f "$cache_file" ]] || [[ "$direnv" -nt "$cache_file" ]]; then
        mkdir -p "${cache_file%/*}"
        "$direnv" hook bash > "$cache_file"
    fi
    source "$cache_file"
    eval "$("$direnv" export bash)"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
