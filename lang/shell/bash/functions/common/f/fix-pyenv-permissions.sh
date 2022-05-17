#!/usr/bin/env bash

koopa_fix_pyenv_permissions() {
    # """
    # Ensure Python pyenv shims have correct permissions.
    # @note Updated 2022-04-07.
    # """
    local pyenv_prefix
    koopa_assert_has_no_args "$#"
    pyenv_prefix="$(koopa_pyenv_prefix)"
    [[ -d "${pyenv_prefix}/shims" ]] || return 0
    koopa_chmod '0777' "${pyenv_prefix}/shims"
    return 0
}
