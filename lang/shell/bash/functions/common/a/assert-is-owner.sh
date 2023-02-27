#!/usr/bin/env bash

koopa_assert_is_owner() {
    # """
    # Assert that the current user owns the koopa installation.
    # @note Updated 2023-02-27.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    if ! koopa_is_owner
    then
        declare -A dict
        dict['prefix']="$(koopa_koopa_prefix)"
        dict['user']="$(koopa_user)"
        koopa_stop "Koopa installation at '${dict['prefix']}' is not \
owned by '${dict['user']}'."
    fi
    return 0
}
