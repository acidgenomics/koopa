#!/usr/bin/env bash

koopa_current_github_tag_version() {
    # """
    # Get the current tag version from GitHub.
    # @note Updated 2023-12-22.
    #
    # @examples
    # > koopa_current_github_tag_version 'acidgenomics/koopa'
    # # 0.14.0
    # """
    local -A app
    local repo
    koopa_assert_has_args "$#"
    app['head']="$(koopa_locate_head)"
    app['jq']="$(koopa_locate_jq)"
    app['sed']="$(koopa_locate_sed)"
    app['sort']="$(koopa_locate_sort)"
    koopa_assert_is_executable "${app[@]}"
    for repo in "$@"
    do
        local -A dict
        dict['repo']="$repo"
        dict['url']="https://api.github.com/repos/${dict['repo']}/tags"
        dict['version']="$( \
            koopa_parse_url "${dict['url']}" \
                | "${app['jq']}" --raw-output '.[].name' \
                | "${app['sort']}" --reverse --version-sort \
                | "${app['head']}" --lines=1 \
                | "${app['sed']}" 's/^v//' \
        )"
        [[ -n "${dict['version']}" ]] || return 1
        koopa_print "${dict['version']}"
    done
    return 0
}
