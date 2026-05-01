#!/usr/bin/env bash

_koopa_assert_is_git_repo() {
    # """
    # Assert that current directory is a Git repo.
    # @note Updated 2023-03-12.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! _koopa_is_git_repo "$arg"
        then
            _koopa_stop "Not a Git repo: '${arg}'."
        fi
    done
    return 0
}
