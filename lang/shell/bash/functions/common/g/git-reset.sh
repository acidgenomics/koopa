#!/usr/bin/env bash

koopa_git_reset() {
    # """
    # Clean and reset a git repo and its submodules.
    # @note Updated 2023-03-12.
    #
    # Note extra '-f' flag in 'git clean' step, which handles nested '.git'
    # directories better.
    #
    # See also:
    # https://gist.github.com/nicktoumpelis/11214362
    # """
    local app repos
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || exit 1
    repos=("$@")
    koopa_is_array_empty "${repos[@]}" && repos[0]="${PWD:?}"
    koopa_assert_is_git_repo "${repos[@]}"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "${repos[@]}"
        do
            repo="$(koopa_realpath "$repo")"
            koopa_alert "Resetting Git repo at '${repo}'."
            koopa_cd "$repo"
            "${app['git']}" clean -dffx
            if [[ -s '.gitmodules' ]]
            then
                # FIXME This needs require the directory as input.
                koopa_git_submodule_init
                "${app['git']}" submodule --quiet foreach --recursive \
                    "${app['git']}" clean -dffx
                "${app['git']}" reset --hard --quiet
                "${app['git']}" submodule --quiet foreach --recursive \
                    "${app['git']}" reset --hard --quiet
            fi
        done
    )
    return 0
}
