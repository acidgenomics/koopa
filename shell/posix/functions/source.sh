#!/bin/sh

_koopa_exec_dir() {
    # """
    # Execute multiple shell scripts in a directory.
    # @note Updated 2020-07-23.
    # """
    # shellcheck disable=SC2039
    local dir file
    dir="${1:?}"
    [ -d "$dir" ] || return 0
    for file in "${dir}/"*'.sh'
    do
        [ -x "$file" ] || continue
        # shellcheck source=/dev/null
        "$file"
    done
    return 0
}

_koopa_source_dir() {
    # """
    # Source multiple shell scripts in a directory.
    # @note Updated 2020-07-23.
    # """
    # shellcheck disable=SC2039
    local dir file
    dir="${1:?}"
    [ -d "$dir" ] || return 0
    for file in "${dir}/"*'.sh'
    do
        [ -f "$file" ] || continue
        # shellcheck source=/dev/null
        . "$file"
    done
    return 0
}
