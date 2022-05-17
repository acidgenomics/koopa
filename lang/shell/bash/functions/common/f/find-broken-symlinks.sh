#!/usr/bin/env bash

koopa_find_broken_symlinks() {
    # """
    # Find broken symlinks.
    # @note Updated 2022-02-17.
    #
    # Currently requires GNU findutils to be installed.
    # """
    local prefix str
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        str="$( \
            koopa_find \
                --engine='find' \
                --min-depth=1 \
                --prefix="$prefix" \
                --sort \
                --type='broken-symlink' \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}
