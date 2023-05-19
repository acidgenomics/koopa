#!/usr/bin/env bash

koopa_assert_is_gitlab_ssh_enabled() {
    # """
    # Assert that current user has SSH key access to GitLab.
    # @note Updated 2023-03-12.
    # """
    koopa_assert_has_no_args "$#"
    if ! koopa_is_gitlab_ssh_enabled
    then
        koopa_stop 'GitLab SSH access is not configured correctly.'
    fi
    return 0
}
