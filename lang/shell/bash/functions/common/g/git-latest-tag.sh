#!/usr/bin/env bash

koopa_git_latest_tag() {
    # """
    # Latest tag of a local git repo.
    # @note Updated 2023-03-12.
    #
    # @examples
    # > koopa_git_latest_tag '/opt/koopa'
    # # v0.12.1
    # """
    local app
    local -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || exit 1
    koopa_assert_is_git_repo "$@"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "$@"
        do
            local rev tag
            koopa_cd "$repo"
            rev="$("${app['git']}" rev-list --tags --max-count=1)"
            tag="$("${app['git']}" describe --tags "$rev")"
            [[ -n "$tag" ]] || return 1
            koopa_print "$tag"
        done
    )
    return 0
}
