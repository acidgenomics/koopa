#!/usr/bin/env bash

_koopa_assert_is_not_symlink() {
    # """
    # Assert that input is not a symbolic link.
    # @note Updated 2020-02-16.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -L "$arg" ]]
        then
            _koopa_stop "Symlink exists: '${arg}'."
        fi
    done
    return 0
}
