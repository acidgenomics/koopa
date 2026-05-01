#!/usr/bin/env bash

_koopa_find_broken_symlinks() {
    # """
    # Find broken symlinks.
    # @note Updated 2022-02-17.
    #
    # Currently requires GNU findutils to be installed.
    # """
    local prefix
    _koopa_assert_has_args "$#"
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local str
        str="$( \
            _koopa_find \
                --engine='find' \
                --min-depth=1 \
                --prefix="$prefix" \
                --sort \
                --type='broken-symlink' \
        )"
        [[ -n "$str" ]] || continue
        _koopa_print "$str"
    done
    return 0
}
