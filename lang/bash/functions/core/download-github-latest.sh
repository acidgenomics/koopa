#!/usr/bin/env bash

_koopa_download_github_latest() {
    # """
    # Download GitHub latest release.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local repo
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for repo in "$@"
    do
        local api_url tag tarball_url
        api_url="https://api.github.com/repos/${repo}/releases/latest"
        tarball_url="$( \
            _koopa_parse_url "$api_url" \
            | _koopa_grep --pattern='tarball_url' \
            | "${app['cut']}" -d ':' -f '2,3' \
            | "${app['tr']}" --delete ' ,"' \
        )"
        tag="$(_koopa_basename "$tarball_url")"
        _koopa_download "$tarball_url" "${tag}.tar.gz"
    done
    return 0
}
