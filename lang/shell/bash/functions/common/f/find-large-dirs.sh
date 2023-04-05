#!/usr/bin/env bash

koopa_find_large_dirs() {
    # """
    # Find large directories.
    # @note Updated 2022-02-16.
    #
    # Results are reverse sorted by size.
    #
    # @examples
    # > koopa_find_large_dirs "${HOME}/monorepo"
    # """
    local -A app
    local prefix
    koopa_assert_has_args "$#"
    koopa_assert_is_dir "$@"
    app['du']="$(koopa_locate_du)"
    app['sort']="$(koopa_locate_sort)"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    for prefix in "$@"
    do
        local str
        prefix="$(koopa_realpath "$prefix")"
        str="$( \
            "${app['du']}" \
                --max-depth=10 \
                --threshold=100000000 \
                "${prefix}"/* \
                2>/dev/null \
            | "${app['sort']}" --numeric-sort \
            | "${app['tail']}" -n 50 \
            || true \
        )"
        [[ -n "$str" ]] || continue
        koopa_print "$str"
    done
    return 0
}
