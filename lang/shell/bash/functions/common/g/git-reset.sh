#!/usr/bin/env bash

koopa_git_reset() {
    # """
    # Clean and reset a git repo and its submodules.
    # @note Updated 2021-11-23.
    #
    # Note extra '-f' flag in 'git clean' step, which handles nested '.git'
    # directories better.
    #
    # See also:
    # https://gist.github.com/nicktoumpelis/11214362
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
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Resetting repo at '${repo}'."
            koopa_cd "$repo"
            koopa_assert_is_git_repo
            "${app[git]}" clean -dffx
            if [[ -s '.gitmodules' ]]
            then
                koopa_git_submodule_init
                "${app[git]}" submodule --quiet foreach --recursive \
                    "${app[git]}" clean -dffx
                "${app[git]}" reset --hard --quiet
                "${app[git]}" submodule --quiet foreach --recursive \
                    "${app[git]}" reset --hard --quiet
            fi
        done
    )
    return 0
}
