#!/usr/bin/env bash

koopa_assert_is_owner() {
    # """
    # Assert that the current user owns the koopa installation.
    # @note Updated 2023-02-27.
    # """
    local dict
    local -A dict
    koopa_assert_has_no_args "$#"
    if ! koopa_is_owner
    then
        dict['prefix']="$(koopa_koopa_prefix)"
        dict['user']="$(koopa_user_name)"
        koopa_stop "Koopa installation at '${dict['prefix']}' is not \
owned by '${dict['user']}'."
    fi
    return 0
}
