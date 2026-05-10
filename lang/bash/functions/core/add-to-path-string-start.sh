#!/usr/bin/env bash

_koopa_add_to_path_string_start() {
    local string
    string="${1:-}"
    local dir
    dir="${2:?}"
    if _koopa_str_detect_posix "$string" "${dir}:"
    then
        string="$( \
            _koopa_remove_from_path_string \
                "$string" "${dir}" \
        )"
    fi
    if [[ -z "$string" ]]
    then
        string="$dir"
    else
        string="${dir}:${string}"
    fi
    _koopa_print "$string"
    return 0
}
