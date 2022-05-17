#!/usr/bin/env bash

koopa_python_system_packages_prefix() {
    # """
    # Python system site packages library prefix.
    # @note Updated 2022-01-31.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [python]="${1:-}"
    )
    [[ -z "${app[python]}" ]] && app[python]="$(koopa_locate_python)"
    koopa_assert_is_installed "${app[python]}"
    declare -A dict
    dict[prefix]="$( \
        "${app[python]}" -c 'import site; print(site.getsitepackages()[0])' \
    )"
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_print "${dict[prefix]}"
    return 0
}
