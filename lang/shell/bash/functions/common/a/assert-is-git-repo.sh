#!/usr/bin/env bash

koopa_assert_is_git_repo() {
    # """
    # Assert that current directory is a git repo.
    # @note Updated 2021-08-19.
    #
    # Intentionally doesn't support input of multiple directories here.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_git_repo
    then
        koopa_stop "Not a Git repo: '${PWD:?}'."
    fi
    return 0
}
