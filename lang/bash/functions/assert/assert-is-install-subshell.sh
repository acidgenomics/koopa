#!/usr/bin/env bash

_koopa_assert_is_install_subshell() {
    # """
    # Assert that call is inside our isolated app installer subshell.
    # @note Updated 2023-08-29.
    # """
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_install_subshell
    then
        _koopa_stop 'Unsupported command.'
    fi
    return 0
}
