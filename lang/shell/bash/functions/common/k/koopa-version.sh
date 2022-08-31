#!/usr/bin/env bash

koopa_koopa_version() {
    # """
    # Koopa version.
    # @note Updated 2022-08-30.
    # """
    local app dict
    declare -A app dict
    koopa_assert_has_no_args "$#"
    app['cat']="$(koopa_locate_cat --allow-system)"
    [[ -x "${app['cat']}" ]] || return 1
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['version_file']="${dict['koopa_prefix']}/VERSION"
    koopa_assert_is_file "${dict['version_file']}"
    dict['version']="$("${app['cat']}" "${dict['version_file']}")"
    koopa_print "${dict['version']}"
    return 0
}
