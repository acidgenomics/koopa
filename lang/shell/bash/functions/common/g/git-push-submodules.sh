#!/usr/bin/env bash

koopa_git_push_submodules() {
    # """
    # Push Git submodules.
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
            koopa_cd "$repo"
            "${app[git]}" submodule update --remote --merge
            "${app[git]}" commit -m 'Update submodules.'
            "${app[git]}" push
        done
    )
    return 0
}
