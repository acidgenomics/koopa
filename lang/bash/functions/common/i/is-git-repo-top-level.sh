#!/usr/bin/env bash

koopa_is_git_repo_top_level() {
    # """
    # Is the working directory the top level of a git repository?
    # @note Updated 2023-03-12.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        [[ -d "$arg" ]] || return 1
        [[ -e "${arg}/.git" ]] || return 1
    done
    return 0
}
