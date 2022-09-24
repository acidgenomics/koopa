#!/usr/bin/env bash

koopa_git_rm_untracked() {
    # """
    # Remove untracked files from git repo.
    # @note Updated 2022-09-24.
    # """
    local app repos
    declare -A app=(
        ['git']="$(koopa_locate_git --allow-system)"
    )
    [[ -x "${app['git']}" ]] || return 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Removing untracked files in '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            "${app['git']}" clean -dfx
        done
    )
    return 0
}
