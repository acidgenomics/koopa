#!/usr/bin/env bash

koopa_git_pull() {
    # """
    # Pull (update) a git repository.
    # @note Updated 2021-11-24.
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
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    repos=("$@")
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Pulling repo at '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            "${app[git]}" fetch --all --quiet
            "${app[git]}" pull --all --no-rebase --recurse-submodules
        done
    )
    return 0
}
