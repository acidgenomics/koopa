#!/usr/bin/env bash

_koopa_current_github_release_version() {
    # """
    # Get the current (latest) release version from GitHub.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > _koopa_current_github_release_version 'acidgenomics/koopa'
    # # 0.14.0
    # """
    local -A app
    local repo
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut)"
    app['sed']="$(_koopa_locate_sed)"
    _koopa_assert_is_executable "${app[@]}"
    for repo in "$@"
    do
        local -A dict
        dict['repo']="$repo"
        dict['url']="https://api.github.com/repos/${dict['repo']}/\
releases/latest"
        dict['version']="$( \
            _koopa_parse_url "${dict['url']}" \
                | _koopa_grep --pattern='"tag_name":' \
                | "${app['cut']}" -d '"' -f '4' \
                | "${app['sed']}" 's/^v//' \
        )"
        [[ -n "${dict['version']}" ]] || return 1
        _koopa_print "${dict['version']}"
    done
    return 0
}
