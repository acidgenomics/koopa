#!/usr/bin/env bash

koopa_r_system_library_prefix() {
    # """
    # R system library prefix.
    # @note Updated 2022-01-31.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    app[rscript]="${app[r]}script"
    koopa_assert_is_installed "${app[rscript]}"
    declare -A dict
    dict[prefix]="$( \
        "${app[rscript]}" \
            --vanilla \
            -e 'cat(normalizePath(tail(.libPaths(), n = 1L)))' \
    )"
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_print "${dict[prefix]}"
    return 0
}
