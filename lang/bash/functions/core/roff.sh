#!/usr/bin/env bash

_koopa_roff() {
    # """
    # Convert roff markdown files to ronn man pages.
    # @note Updated 2023-10-25.
    # """
    local -A app dict
    local -a files
    _koopa_assert_has_no_args "$#"
    app['ronn']="$(_koopa_locate_ronn)"
    _koopa_assert_is_executable "${app[@]}"
    dict['man_prefix']="$(_koopa_man_prefix)"
    readarray -t files <<< "$( \
        _koopa_find \
            --pattern='*.ronn' \
            --prefix="${dict['man_prefix']}" \
            --sort \
            --type='f' \
    )"
    _koopa_assert_is_array_non_empty "${files[@]}"
    "${app['ronn']}" --roff "${files[@]}"
    return 0
}
