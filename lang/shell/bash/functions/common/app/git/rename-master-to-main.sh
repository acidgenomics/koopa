#!/usr/bin/env bash

koopa::git_rename_master_to_main() { # {{{1
    # """
    # Rename default branch from "master" to "main".
    # @note Updated 2021-11-23.
    #
    # @examples
    # > koopa::git_rename_master_to_main "${HOME}/git/example"
    # """
    local app dict repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
    )
    declare -A dict=(
        [origin]='origin'
        [old_branch]='master'
        [new_branch]='main'
    )
    repos=("$@")
    koopa::is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa::assert_is_dir "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            koopa::cd "$repo"
            koopa::assert_is_git_repo
            "${app[git]}" branch -m \
                "${dict[old_branch]}" \
                "${dict[new_branch]}"
            "${app[git]}" fetch "${dict[origin]}"
            "${app[git]}" branch \
                -u "${dict[origin]}/${dict[new_branch]}" \
                "${dict[new_branch]}"
            "${app[git]}" remote set-head "${dict[origin]}" -a
        done
    )
    return 0
}
