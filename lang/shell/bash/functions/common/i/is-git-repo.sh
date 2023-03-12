#!/usr/bin/env bash

# FIXME Allow input of a directory.

koopa_is_git_repo() {
    # """
    # Is the working directory a git repository?
    # @note Updated 2022-02-23.
    #
    # @seealso
    # - https://stackoverflow.com/questions/2180270
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app
    app['git']="$(koopa_locate_git)"
    [[ -x "${app['git']}" ]] || return 1
    koopa_is_git_repo_top_level "${PWD:?}" && return 0
    "${app['git']}" rev-parse --git-dir >/dev/null 2>&1 || return 1
    return 0
}
