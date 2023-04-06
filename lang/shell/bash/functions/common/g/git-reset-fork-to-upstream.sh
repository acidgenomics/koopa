#!/usr/bin/env bash

koopa_git_reset_fork_to_upstream() {
    # """
    # Reset Git fork to upstream.
    # @note Updated 2023-04-06.
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || exit 1
    koopa_assert_is_git_repo "$@"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "$@"
        do
            local -A dict
            koopa_cd "$repo"
            dict['branch']="$(koopa_git_default_branch "${PWD:?}")"
            dict['origin']='origin'
            dict['upstream']='upstream'
            "${app['git']}" checkout "${dict['branch']}"
            "${app['git']}" fetch "${dict['upstream']}"
            "${app['git']}" reset --hard "${dict['upstream']}/${dict['branch']}"
            "${app['git']}" push "${dict['origin']}" "${dict['branch']}" --force
        done
    )
    return 0
}
