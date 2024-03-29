#!/usr/bin/env bash

koopa_find_large_files() {
    # """
    # Find large files.
    # @note Updated 2022-02-16.
    #
    # Results are sorted alphabetically currently, not by size.
    #
    # @seealso
    # - https://unix.stackexchange.com/questions/140367/
    #
    # @examples
    # > koopa_find_large_files "${HOME}/monorepo"
    # """
    local -A app
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    app['head']="$(koopa_locate_head --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local str
        str="$( \
            koopa_find \
                --min-depth=1 \
                --prefix="$prefix" \
                --size='+100000000c' \
                --sort \
                --type='f' \
            | "${app['head']}" -n 50 \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}
