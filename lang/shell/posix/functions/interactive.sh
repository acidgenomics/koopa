#!/bin/sh
# koopa nolint=coreutils

# FIXME Rename this with prompt prefix.
_koopa_git_branch() { # {{{1
    # """
    # Current git branch name.
    # @note Updated 2020-07-05.
    #
    # This is used in prompt, so be careful with assert checks.
    #
    # Handles detached HEAD state.
    #
    # Alternatives:
    # > git name-rev --name-only HEAD
    # > git rev-parse --abbrev-ref HEAD
    #
    # @seealso
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    # """
    local branch
    _koopa_is_git || return 0
    _koopa_is_installed git || return 0
    branch="$(git symbolic-ref --short -q HEAD 2>/dev/null)"
    _koopa_print "$branch"
    return 0
}
