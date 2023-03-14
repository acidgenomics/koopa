#!/usr/bin/env bash

# FIXME Support directory input.

koopa_is_git_repo_clean() {
    # """
    # Is the working directory git repo clean, or does it have unstaged changes?
    # @note Updated 2023-03-12.
    #
    # This is used in prompt, so be careful with assert checks.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    # """
    local prefix
    koopa_assert_has_args "$#"
    for prefix in "$@"
    do
        koopa_is_git_repo "$prefix" || return 1
        koopa_git_repo_has_unstaged_changes "$prefix" && return 1
        koopa_git_repo_needs_pull_or_push "$prefix" && return 1
    done
    return 0
}
