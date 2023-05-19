#!/usr/bin/env bash

koopa_assert_is_executable() {
    # """
    # Assert that input is executable.
    # @note Updated 2023-04-05.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -z "$arg" ]]
        then
            koopa_stop 'Missing executable.'
        fi
        if [[ ! -x "$arg" ]]
        then
            koopa_stop "Not executable: '${arg}'."
        fi
    done
    return 0
}
