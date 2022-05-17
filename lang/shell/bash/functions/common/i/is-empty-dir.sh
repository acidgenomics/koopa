#!/usr/bin/env bash

koopa_is_empty_dir() {
    # """
    # Is the input an empty directory?
    # @note Updated 2022-02-24.
    #
    # @examples
    # > koopa_mkdir 'aaa' 'bbb'
    # > koopa_is_empty_dir 'aaa' 'bbb'
    # > koopa_rm 'aaa' 'bbb'
    # """
    local prefix
    koopa_assert_has_args "$#"
    for prefix in "$@"
    do
        local out
        [[ -d "$prefix" ]] || return 1
        out="$(\
            koopa_find \
            --empty \
            --engine='find' \
            --max-depth=0 \
            --min-depth=0 \
            --prefix="$prefix" \
            --type='d'
        )"
        [[ -n "$out" ]] || return 1
    done
    return 0
}
