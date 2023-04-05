#!/usr/bin/env bash

koopa_git_push_submodules() {
    # """
    # Push Git submodules.
    # @note Updated 2023-03-12.
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
            koopa_cd "$repo"
            "${app['git']}" submodule update --remote --merge
            "${app['git']}" commit -m 'Update submodules.'
            "${app['git']}" push
        done
    )
    return 0
}
