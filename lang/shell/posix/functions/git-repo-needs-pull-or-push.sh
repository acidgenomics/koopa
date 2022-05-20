#!/bin/sh

koopa_git_repo_needs_pull_or_push() {
    # """
    # Does the current git repo need a pull or push?
    # @note Updated 2021-08-19.
    #
    # This will return an expected fatal warning when no upstream exists.
    # We're handling this case by piping errors to '/dev/null'.
    # """
    local rev_1 rev_2
    rev_1="$(git rev-parse 'HEAD' 2>/dev/null)"
    rev_2="$(git rev-parse '@{u}' 2>/dev/null)"
    [ "$rev_1" != "$rev_2" ]
}
