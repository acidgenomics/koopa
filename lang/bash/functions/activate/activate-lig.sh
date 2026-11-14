#!/usr/bin/env bash

_koopa_activate_lig_part() {
    local part="$1"
    local lig="${KOOPA_PREFIX:?}/bin/lig"
    [[ -x "$lig" ]] || return 0
    (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4) )) || return 0
    [[ "$-" == *i* ]] || return 0
    [[ -z "${LIG_DISABLE:-}" ]] || return 0
    if [[ "$part" == 'pre' && -t 0 && -t 1 ]]
    then
        # A login argv0 can make $BASH point to $SHELL rather than the running Bash.
        local bash_path
        bash_path="$("$lig" shell-path "$$")" || return 0
        [[ -x "$bash_path" ]] || return 0
        local BASH="$bash_path"
    fi
    local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/lig-bash-${part}.sh"
    if [[ ! -s "$cache_file" ]] || [[ "$lig" -nt "$cache_file" ]]
    then
        mkdir -p "${cache_file%/*}" || return 1
        local tmp_file="${cache_file}.$$"
        if ! "$lig" init bash "$part" > "$tmp_file"
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
    # shellcheck source=/dev/null
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
