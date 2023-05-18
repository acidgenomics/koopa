#!/usr/bin/env bash

koopa_assert_is_non_existing() {
    # """
    # Assert that input does not exist on disk.
    # @note Updated 2020-02-16.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if [[ -e "$arg" ]]
        then
            koopa_stop "Exists: '${arg}'."
        fi
    done
    return 0
}
