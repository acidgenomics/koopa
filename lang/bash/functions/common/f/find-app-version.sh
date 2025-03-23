#!/usr/bin/env bash

koopa_find_app_version() {
    # """
    # Find the latest application version.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['sort']="$(koopa_locate_sort)"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['name']="${1:?}"
    dict['prefix']="${dict['app_prefix']}/${dict['name']}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['hit']="$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['prefix']}" \
            --type='d' \
        | "${app['sort']}" \
        | "${app['tail']}" -n 1 \
    )"
    [[ -d "${dict['hit']}" ]] || return 1
    dict['hit_bn']="$(koopa_basename "${dict['hit']}")"
    koopa_print "${dict['hit_bn']}"
    return 0
}
