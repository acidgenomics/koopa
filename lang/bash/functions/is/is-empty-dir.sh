#!/usr/bin/env bash

_koopa_is_empty_dir() {
    # """
    # Is the input an empty directory?
    # @note Updated 2022-02-24.
    #
    # @examples
    # > _koopa_mkdir 'aaa' 'bbb'
    # > _koopa_is_empty_dir 'aaa' 'bbb'
    # > _koopa_rm 'aaa' 'bbb'
    # """
    local prefix
    _koopa_assert_has_args "$#"
    for prefix in "$@"
    do
        local out
        [[ -d "$prefix" ]] || return 1
        out="$(\
            _koopa_find \
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
