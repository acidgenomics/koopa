#!/usr/bin/env bash

koopa_current_github_tag() {
    # """
    # Get the current GitHub repo tag.
    # @note Updated 2023-12-22.
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['gh']="$(koopa_locate_gh)"
    app['head']="$(koopa_locate_head)"
    app['jq']="$(koopa_locate_jq)"
    app['sort']="$(koopa_locate_sort)"
    koopa_assert_is_executable "${app[@]}"
    dict['repo']="${1:?}"
    dict['url']="https://api.github.com/repos/${dict['repo']}/tags"
    dict['version']="$( \
        "${app['gh']}" api "${dict['url']}" \
            | "${app['jq']}" --raw-output '.[].name' \
            | "${app['sort']}" -nr \
            | "${app['head']}" -n 1 \
    )"
    [[ -n "${dict['version']}" ]] || return 1
    koopa_print "${dict['version']}"
    return 0
}
