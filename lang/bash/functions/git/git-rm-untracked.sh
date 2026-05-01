#!/usr/bin/env bash

_koopa_git_rm_untracked() {
    # """
    # Remove untracked files from git repo.
    # @note Updated 2023-04-05.
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
            _koopa_alert "Removing untracked files in '${repo}'."
            _koopa_cd "$repo"
            _koopa_assert_is_git_repo
            "${app['git']}" clean -dfx
        done
    )
    return 0
}
