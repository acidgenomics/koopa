#!/usr/bin/env zsh

_koopa_activate_lig_part() {
    local part="$1"
    local lig="${KOOPA_PREFIX:?}/bin/lig"
    [[ -x "$lig" ]] || return 0
    [[ -o interactive ]] || return 0
    [[ -z "${LIG_DISABLE:-}" ]] || return 0
    local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/lig-zsh-${part}.sh"
    if [[ ! -s "$cache_file" ]] || [[ "$lig" -nt "$cache_file" ]]
    then
        mkdir -p "${cache_file%/*}" || return 1
        local tmp_file="${cache_file}.$$"
        if ! "$lig" init zsh "$part" > "$tmp_file"
        then
            rm -f "$tmp_file"
            return 1
        fi
        if [[ ! -s "$tmp_file" ]] || ! mv -f "$tmp_file" "$cache_file"
        then
            rm -f "$tmp_file"
            return 1
        fi
    fi
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    source "$cache_file"
    local lig_status=$?
    if [[ "$nounset" -eq 1 ]]
    then
        set -o nounset
    fi
    return "$lig_status"
}

_koopa_activate_lig_pre() {
    _koopa_activate_lig_part 'pre'
}

_koopa_activate_lig_post() {
    _koopa_activate_lig_part 'post'
}
