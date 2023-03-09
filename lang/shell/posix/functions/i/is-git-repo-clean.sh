#!/bin/sh

# FIXME Move this to Bash.

_koopa_is_git_repo_clean() {
    # """
    # Is the working directory git repo clean, or does it have unstaged changes?
    # @note Updated 2022-01-20.
    #
    # This is used in prompt, so be careful with assert checks.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    # """
    _koopa_is_git_repo || return 1
    _koopa_git_repo_has_unstaged_changes && return 1
    _koopa_git_repo_needs_pull_or_push && return 1
    return 0
}
