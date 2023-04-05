#!/usr/bin/env bash

koopa_git_commit_date() {
    # """
    # Date of last git commit.
    # @note Updated 2023-03-12.
    #
    # Alternative approach:
    # > "${app['git']}" log -1 --format='%cd'
    #
    # @examples
    # > koopa_git_commit_date "${HOME}/git/monorepo"
    # # 2022-08-04
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['date']="$(koopa_locate_date --allow-system)"
    app['git']="$(koopa_locate_git --allow-system)"
    app['xargs']="$(koopa_locate_xargs --allow-system)"
    [[ -x "${app['date']}" ]] || exit 1
    [[ -x "${app['git']}" ]] || exit 1
    [[ -x "${app['xargs']}" ]] || exit 1
    koopa_assert_is_git_repo "$@"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "$@"
        do
            local string
            koopa_cd "$repo"
            string="$( \
                "${app['git']}" log -1 --format='%at' \
                | "${app['xargs']}" -I '{}' \
                "${app['date']}" -d '@{}' '+%Y-%m-%d' \
                2>/dev/null \
                || true \
            )"
            [[ -n "$string" ]] || return 1
            koopa_print "$string"
        done
    )
    return 0
}
