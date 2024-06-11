#!/usr/bin/env bash

koopa_r_system_packages_non_base() {
    # """
    # Print non-base packages (i.e. "recommended") installed in system library.
    # @note Updated 2024-05-28.
    # """
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    dict['string']="$( \
        koopa_r_script \
            --r="${app['r']}" \
            --vanilla \
            'system-packages-non-base.R' \
    )"
    [[ -n "${dict['string']}" ]] || return 0
    koopa_print "${dict['string']}"
    return 0
}
