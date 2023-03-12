#!/usr/bin/env bash

koopa_is_git_repo_top_level() {
    # """
    # Is the working directory the top level of a git repository?
    # @note Updated 2023-03-12.
    # """
    local prefix
    koopa_assert_has_args_le "$#" 1
    prefix="${1:-${PWD:?}}"
    [[ -e "${prefix}/.git" ]]
}
