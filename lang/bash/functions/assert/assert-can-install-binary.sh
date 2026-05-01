#!/usr/bin/env bash

_koopa_assert_can_install_binary() {
    # """
    # Assert that current user has permission to install binary shared apps.
    # @note Updated 2023-10-13.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_can_install_binary
    then
        _koopa_stop 'No binary file access.'
    fi
    return 0
}
