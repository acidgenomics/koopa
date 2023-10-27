#!/usr/bin/env bash

koopa_roff() {
    # """
    # Convert roff markdown files to ronn man pages.
    # @note Updated 2023-10-25.
    # """
    local -A app dict
    local -a files
    koopa_assert_has_no_args "$#"
    app['ronn']="$(koopa_locate_ronn)"
    koopa_assert_is_executable "${app[@]}"
    dict['man_prefix']="$(koopa_man_prefix)"
    readarray -t files <<< "$( \
        koopa_find \
            --pattern='*.ronn' \
            --prefix="${dict['man_prefix']}" \
            --sort \
            --type='f' \
    )"
    koopa_assert_is_array_non_empty "${files[@]}"
    "${app['ronn']}" --roff "${files[@]}"
    return 0
}
