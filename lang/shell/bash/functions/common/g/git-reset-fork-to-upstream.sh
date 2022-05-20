#!/usr/bin/env bash

koopa_git_reset_fork_to_upstream() {
    # """
    # Reset Git fork to upstream.
    # @note Updated 2021-11-23.
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa_locate_git)"
    )
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            local dict
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            declare -A dict=(
                [branch]="$(koopa_git_default_branch)"
                [origin]='origin'
                [upstream]='upstream'
            )
            "${app[git]}" checkout "${dict[branch]}"
            "${app[git]}" fetch "${dict[upstream]}"
            "${app[git]}" reset --hard "${dict[upstream]}/${dict[branch]}"
            "${app[git]}" push "${dict[origin]}" "${dict[branch]}" --force
        done
    )
    return 0
}
