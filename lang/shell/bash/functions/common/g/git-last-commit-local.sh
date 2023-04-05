#!/usr/bin/env bash

koopa_git_last_commit_local() {
    # """
    # Last git commit of local repository.
    # @note Updated 2023-03-12.
    #
    # Alternate approach:
    # Can use '%h' for abbreviated commit identifier.
    # > git log --format="%H" -n 1
    #
    # @examples
    # > koopa_git_last_commit_local "${HOME}/git/monorepo"
    # # 9b7217c27858dd7ebffdf5a8ba66a6ea56ac5e1d
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || exit 1
    dict['ref']='HEAD'
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
                "${app['git']}" rev-parse "${dict['ref']}" \
                2>/dev/null \
                || true \
            )"
            [[ -n "$string" ]] || return 1
            koopa_print "$string"
        done
    )
    return 0
}
