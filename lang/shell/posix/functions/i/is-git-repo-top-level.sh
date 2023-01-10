#!/bin/sh

koopa_is_git_repo_top_level() {
    # """
    # Is the working directory the top level of a git repository?
    # @note Updated 2021-08-19.
    # """
    local dir
    dir="${1:-.}"
    [ -e "${dir}/.git" ]
}
