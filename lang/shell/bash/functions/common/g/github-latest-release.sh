#!/usr/bin/env bash

koopa_github_latest_release() {
    # """
    # Get the latest release version from GitHub.
    # @note Updated 2022-03-21.
    #
    # @examples
    # > koopa_github_latest_release 'acidgenomics/koopa'
    # """
    local app repo
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [sed]="$(koopa_locate_sed)"
    )
    for repo in "$@"
    do
        local dict
        declare -A dict
        dict[repo]="$repo"
        dict[url]="https://api.github.com/repos/${dict[repo]}/releases/latest"
        dict[str]="$( \
            koopa_parse_url "${dict[url]}" \
                | koopa_grep --pattern='"tag_name":' \
                | "${app[cut]}" -d '"' -f '4' \
                | "${app[sed]}" 's/^v//' \
        )"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
    done
    return 0
}
