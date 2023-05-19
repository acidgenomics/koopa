#!/usr/bin/env bash

koopa_git_pull() {
    # """
    # Pull (update) a git repository.
    # @note Updated 2023-04-05.
    #
    # Can quiet down with 'git submodule --quiet' here.
    # Note that git checkout, fetch, and pull also support '--quiet'.
    #
    # Potentially useful approach for submodules:
    # > git submodule update --init --merge --remote
    #
    # @seealso
    # - https://git-scm.com/docs/git-submodule/2.10.2
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['git']="$(koopa_locate_git --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_git_repo "$@"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "$@"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Pulling Git repo at '${repo}'."
            koopa_cd "$repo"
            "${app['git']}" fetch --all --quiet
            "${app['git']}" pull --all --no-rebase --recurse-submodules
        done
    )
    return 0
}
