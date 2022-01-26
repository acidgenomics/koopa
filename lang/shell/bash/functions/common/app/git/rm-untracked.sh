#!/usr/bin/env bash

koopa::git_rm_untracked() { # {{{1
    # """
    # Remove untracked files from git repo.
    # @note Updated 2021-11-23.
    # """
    local app repos
    declare -A app=(
        [git]="$(koopa::locate_git)"
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
            repo="$(koopa::realpath "$repo")"
            koopa::alert "Removing untracked files in '${repo}'."
            koopa::cd "$repo"
            koopa::assert_is_git_repo
            "${app[git]}" clean -dfx
        done
    )
    return 0
}
