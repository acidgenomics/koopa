#!/usr/bin/env bash

_koopa_git_reset() {
    # """
    # Clean and reset a git repo and its submodules.
    # @note Updated 2023-05-24.
    #
    # Note extra '-f' flag in 'git clean' step, which handles nested '.git'
    # directories better.
    #
    # See also:
    # https://gist.github.com/nicktoumpelis/11214362
    # """
    local -A app
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_git_repo "$@"
    # Using a single subshell here to avoid performance hit during looping.
    # This single subshell is necessary so we don't change working directory.
    (
        local repo
        for repo in "$@"
        do
            repo="$(_koopa_realpath "$repo")"
            _koopa_alert "Resetting Git repo at '${repo}'."
            _koopa_cd "$repo"
            "${app['git']}" clean -dffx
            if [[ -s '.gitmodules' ]]
            then
                _koopa_git_submodule_init "$repo"
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
