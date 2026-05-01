#!/usr/bin/env bash

_koopa_assert_is_existing() {
    # """
    # Assert that input exists on disk.
    # @note Updated 2020-02-16.
    #
    # Note that '-e' flag returns true for file, dir, or symlink.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ ! -e "$arg" ]]
        then
            _koopa_stop "Does not exist: '${arg}'."
        fi
    done
    return 0
}
