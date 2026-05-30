#!/usr/bin/env zsh

_koopa_remove_from_path_string() {
    local str="${1:?}"
    local dir="${2:?}"
    local -a parts
    parts=("${(@s/:/)str}")
    parts=("${(@)parts:#${dir}}")
    local result="${(j/:/)parts}"
    [[ -n "$result" ]] || return 1
    _koopa_print "$result"
    return 0
}
