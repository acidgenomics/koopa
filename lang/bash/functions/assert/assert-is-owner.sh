#!/usr/bin/env bash

_koopa_assert_is_owner() {
    # """
    # Assert that the current user owns the koopa installation.
    # @note Updated 2023-02-27.
    # """
    local -A dict
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_owner
    then
        dict['prefix']="$(_koopa_koopa_prefix)"
        dict['user']="$(_koopa_user_name)"
        _koopa_stop "Koopa installation at '${dict['prefix']}' is not \
owned by '${dict['user']}'."
    fi
    return 0
}
