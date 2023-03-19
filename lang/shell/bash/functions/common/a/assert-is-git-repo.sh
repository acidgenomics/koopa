#!/usr/bin/env bash

koopa_assert_is_git_repo() {
    # """
    # Assert that current directory is a Git repo.
    # @note Updated 2023-03-12.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa_is_git_repo "$arg"
        then
            koopa_stop "Not a Git repo: '${arg}'."
        fi
    done
    return 0
}
