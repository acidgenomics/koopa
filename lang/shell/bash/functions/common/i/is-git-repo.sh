#!/usr/bin/env bash

koopa_is_git_repo() {
    # """
    # Is the working directory a git repository?
    # @note Updated 2023-03-12.
    #
    # @seealso
    # - https://stackoverflow.com/questions/2180270
    # """
    local app arg
    koopa_assert_has_args "$#"
    declare -A app
    app['git']="$(koopa_locate_git --allow-system)"
    [[ -x "${app['git']}" ]] || return 1
    for arg in "$@"
    do
        [[ -d "$arg" ]] || return 1
        koopa_is_git_repo_top_level "$arg" || return 1
        "${app['git']}" rev-parse --git-dir >/dev/null 2>&1 || return 1
    done
    return 0
}
