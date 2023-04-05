#!/usr/bin/env bash

koopa_git_remote_url() {
    # """
    # Return the Git remote URL for origin.
    # @note Updated 2023-03-12.
    #
    # @examples
    # > koopa_git_remote_url '/opt/koopa'
    # # https://github.com/acidgenomics/koopa.git
    # """
    local app
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || exit 1
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
                "${app['git']}" config --get 'remote.origin.url' \
                || true \
            )"
            [[ -n "$string" ]] || return 1
            koopa_print "$string"
        done
    )
    return 0
}
