#!/usr/bin/env bash

koopa_download_github_latest() {
    # """
    # Download GitHub latest release.
    # @note Updated 2022-08-30.
    # """
    local api_url app repo tag tarball_url
    koopa_assert_has_args "$#"
    declare -A app=(
        ['cut']="$(koopa_locate_cut --allow-system)"
        ['tr']="$(koopa_locate_tr --allow-system)"
    )
    [[ -x "${app['cut']}" ]] || return 1
    [[ -x "${app['tr']}" ]] || return 1
    for repo in "$@"
    do
        api_url="https://api.github.com/repos/${repo}/releases/latest"
        tarball_url="$( \
            koopa_parse_url "$api_url" \
            | koopa_grep --pattern='tarball_url' \
            | "${app['cut']}" -d ':' -f '2,3' \
            | "${app['tr']}" --delete ' ,"' \
        )"
        tag="$(koopa_basename "$tarball_url")"
        koopa_download "$tarball_url" "${tag}.tar.gz"
    done
    return 0
}
