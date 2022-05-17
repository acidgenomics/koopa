#!/usr/bin/env bash

koopa_assert_is_github_ssh_enabled() {
    # """
    # Assert that current user has SSH key access to GitHub.
    # @note Updated 2020-02-11.
    # """
    if ! koopa_is_github_ssh_enabled
    then
        koopa_stop 'GitHub SSH access is not configured correctly.'
    fi
    return 0
}
