#!/usr/bin/env bash

_koopa_source_dir() {
    # """
    # Source multiple shell scripts in a directory.
    # @note Updated 2022-02-17.
    # """
    local file prefix
    _koopa_assert_has_args_eq "$#" 1
    prefix="${1:?}"
    _koopa_assert_is_dir "$prefix"
    for file in "${prefix}/"*'.sh'
    do
        [[ -f "$file" ]] || continue
        # shellcheck source=/dev/null
        . "$file"
    done
    return 0
}
