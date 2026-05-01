#!/usr/bin/env bash

_koopa_koopa_version() {
    # """
    # Koopa version.
    # @note Updated 2022-08-30.
    # """
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['cat']="$(_koopa_locate_cat --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['version_file']="${dict['koopa_prefix']}/VERSION"
    _koopa_assert_is_file "${dict['version_file']}"
    dict['version']="$("${app['cat']}" "${dict['version_file']}")"
    _koopa_print "${dict['version']}"
    return 0
}
