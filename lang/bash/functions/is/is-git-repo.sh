#!/usr/bin/env bash

_koopa_is_git_repo() {
    # """
    # Is the working directory a git repository?
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://stackoverflow.com/questions/2180270
    # """
    local -A app
    local repo
    _koopa_assert_has_args "$#"
    app['git']="$(_koopa_locate_git --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    (
        for repo in "$@"
        do
            [[ -d "$repo" ]] || return 1
            _koopa_is_git_repo_top_level "$repo" || return 1
            _koopa_cd "$repo"
            "${app['git']}" rev-parse --git-dir >/dev/null 2>&1 || return 1
        done
        return 0
    )
}
