#!/usr/bin/env bash

koopa_current_github_release_version() {
    # """
    # Get the current (latest) release version from GitHub.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > koopa_current_github_release_version 'acidgenomics/koopa'
    # # 0.14.0
    # """
    local -A app
    local repo
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut)"
    app['sed']="$(koopa_locate_sed)"
    koopa_assert_is_executable "${app[@]}"
    for repo in "$@"
    do
        local -A dict
        dict['repo']="$repo"
        dict['url']="https://api.github.com/repos/${dict['repo']}/\
releases/latest"
        dict['version']="$( \
            koopa_parse_url "${dict['url']}" \
                | koopa_grep --pattern='"tag_name":' \
                | "${app['cut']}" -d '"' -f '4' \
                | "${app['sed']}" 's/^v//' \
        )"
        [[ -n "${dict['version']}" ]] || return 1
        koopa_print "${dict['version']}"
    done
    return 0
}
