#!/usr/bin/env bash

_koopa_assert_is_gitlab_ssh_enabled() {
    # """
    # Assert that current user has SSH key access to GitLab.
    # @note Updated 2023-03-12.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_gitlab_ssh_enabled
    then
        _koopa_stop 'GitLab SSH access is not configured correctly.'
    fi
    return 0
}
