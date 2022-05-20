#!/usr/bin/env bash

koopa_exec_dir() {
    # """
    # Execute multiple shell scripts in a directory.
    # @note Updated 2022-01-20.
    # """
    local file prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        koopa_assert_is_dir "$prefix"
        for file in "${prefix}/"*'.sh'
        do
            [ -x "$file" ] || continue
            # shellcheck source=/dev/null
            "$file"
        done
    done
    return 0
}
