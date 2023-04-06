#!/usr/bin/env bash

koopa_detab() {
    # """
    # Detab files.
    # @note Updated 2022-05-20.
    # """
    local app file
    local -A app
    koopa_assert_has_args "$#"
    app['vim']="$(koopa_locate_vim)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        "${app['vim']}" \
            -c 'set expandtab tabstop=4 shiftwidth=4' \
            -c ':%retab' \
            -c ':wq' \
            -E -s "$file"
    done
    return 0
}
