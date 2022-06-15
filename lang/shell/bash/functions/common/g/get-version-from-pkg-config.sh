#!/usr/bin/env bash

# FIXME Need to add support for opt prefix here.

koopa_get_version_from_pkg_config() {
    # """
    # Get a library version via 'pkg-config'.
    # @note Updated 2022-06-15.
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [pkg_config]="$(koopa_locate_pkg_config)"
    )
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
        [pkg]="${1:?}"
        [pkg_config_path]="${PKG_CONFIG_PATH:-}"
    )
    dict[pkgconfig]="${dict[opt_prefix]}/${dict[pkg]}/lib/pkgconfig"
    [[ -d "${dict[pkgconfig]}" ]] || return 1
    koopa_add_to_pkg_config_path "${dict[pkgconfig]}"
    dict[str]="$("${app[pkg_config]}" --modversion "${dict[pkg]}")"
    if [[ -n "${dict[pkg_config_path]}" ]]
    then
        PKG_CONFIG_PATH="${dict[pkg_config_path]}"
        export PKG_CONFIG_PATH
    else
        unset -v PKG_CONFIG_PATH
    fi
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}
