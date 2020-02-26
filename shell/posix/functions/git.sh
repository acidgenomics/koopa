#!/bin/sh
# shellcheck disable=SC2039

_koopa_git_last_commit_local() {  # {{{1
    # """
    # Last git commit of local repository.
    # @note Updated 2020-02-26.
    #
    # Alternate:
    # Can use '%h' for abbreviated commit ID.
    # > git log --format="%H" -n 1
    # """
    _koopa_is_git || return 1
    local x
    x="$(git rev-parse HEAD)"
    echo "$x"
    return 0
}

_koopa_git_last_commit_remote() {  # {{{1
    # """
    # Last git commit of remote repository.
    # @note Updated 2020-02-26.
    #
    # Instead of 'HEAD', can use 'refs/heads/master'
    # """
    local url
    url="${1:?}"
    local x
    x="$(git ls-remote "$url" HEAD)"
    echo "$x"
    return 0
}
