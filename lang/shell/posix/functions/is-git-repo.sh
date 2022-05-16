#!/bin/sh

koopa_is_git_repo() { # {{{1i
    # """
    # Is the working directory a git repository?
    # @note Updated 2022-02-23.
    # @seealso
    # - https://stackoverflow.com/questions/2180270
    # """
    koopa_is_git_repo_top_level '.' && return 0
    git rev-parse --git-dir >/dev/null 2>&1 || return 1
    return 0
}
