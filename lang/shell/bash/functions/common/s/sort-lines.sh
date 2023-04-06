#!/usr/bin/env bash

koopa_sort_lines() {
    # """
    # Sort lines.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['vim']="$(koopa_locate_vim)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app['vim']}" \
            -c ':sort' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}
