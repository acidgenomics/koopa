#!/usr/bin/env bash

koopa_fix_rbenv_permissions() {
    # """
    # Ensure Ruby rbenv shims have correct permissions.
    # @note Updated 2022-04-07.
    # """
    local rbenv_prefix
    koopa_assert_has_no_args "$#"
    rbenv_prefix="$(koopa_rbenv_prefix)"
    [[ -d "${rbenv_prefix}/shims" ]] || return 0
    koopa_chmod '0777' "${rbenv_prefix}/shims"
    return 0
}
