#!/usr/bin/env bash

_koopa_find_empty_dirs() {
    # """
    # Find empty directories.
    # @note Updated 2022-02-24.
    # """
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
        str="$( \
            _koopa_find \
                --empty \
                --prefix="$prefix" \
                --sort \
                --type='d' \
        )"
        [[ -n "$str" ]] || continue
        _koopa_print "$str"
    done
    return 0
}
