#!/usr/bin/env bash

koopa_find_empty_dirs() {
    # """
    # Find empty directories.
    # @note Updated 2022-02-24.
    # """
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
        str="$( \
            koopa_find \
                --empty \
                --prefix="$prefix" \
                --sort \
                --type='d' \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}
