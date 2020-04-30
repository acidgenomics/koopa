#!/bin/sh
# shellcheck disable=SC2039

_koopa_git_branch() {  # {{{1
    # """
    # Current git branch name.
    # @note Updated 2020-04-29.
    #
    # Handles detached HEAD state.
    #
    # Alternatives:
    # > git name-rev --name-only HEAD
    # > git rev-parse --abbrev-ref HEAD
    #
    # See also:
    # - _koopa_assert_is_git
    # - https://git.kernel.org/pub/scm/git/git.git/tree/contrib/completion/
    #       git-completion.bash?id=HEAD
    # """
    _koopa_is_git || return 1
    local branch
    branch="$(git symbolic-ref --short -q HEAD 2>/dev/null)"
    _koopa_print "$branch"
}

_koopa_git_clone() {  # {{{1
    # """
    # Quietly clone a git repository.
    # @note Updated 2020-02-15.
    # """
    local repo
    repo="${1:?}"
    local target
    target="${2:?}"
    if [ -d "$target" ]
    then
        _koopa_note "Cloned: '${target}'."
        return 0
    fi
    git clone --quiet --recursive "$repo" "$target"
    return 0
}

_koopa_git_last_commit_local() {  # {{{1
    # """
    # Last git commit of local repository.
    # @note Updated 2020-04-08.
    #
    # Alternate:
    # Can use '%h' for abbreviated commit ID.
    # > git log --format="%H" -n 1
    # """
    _koopa_is_git || return 1
    local x
    x="$(git rev-parse HEAD 2>/dev/null)"
    _koopa_print "$x"
}

_koopa_git_last_commit_remote() {  # {{{1
    # """
    # Last git commit of remote repository.
    # @note Updated 2020-04-08.
    #
    # Instead of 'HEAD', can use 'refs/heads/master'
    # """
    local url
    url="${1:?}"
    local x
    x="$(git ls-remote "$url" HEAD 2>/dev/null)"
    _koopa_print "$x"
}
