#!/usr/bin/env bash

_koopa_remove_from_path_string() {
    local str="${1:?}"
    local dir="${2:?}"
    local IFS=':'
    local -a parts=()
    local d
    for d in $str
    do
        [[ "$d" != "$dir" ]] && parts+=("$d")
    done
    local result="${parts[*]}"
    [[ -n "$result" ]] || return 1
    _koopa_print "$result"
    return 0
}
