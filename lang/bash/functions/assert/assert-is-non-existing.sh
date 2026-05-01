#!/usr/bin/env bash

_koopa_assert_is_non_existing() {
    # """
    # Assert that input does not exist on disk.
    # @note Updated 2020-02-16.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -e "$arg" ]]
        then
            _koopa_stop "Exists: '${arg}'."
        fi
    done
    return 0
}
