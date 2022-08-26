#!/usr/bin/env bash

koopa_get_version_from_pkg_config() {
    # """
    # Get a library version via 'pkg-config'.
    # @note Updated 2022-08-26.
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        ['pkg_config']="$(koopa_locate_pkg_config)"
    )
    [[ -x "${app['pkg_config']}" ]] || return 1
    declare -A dict=(
        ['app_name']=''
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['pc_name']=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--app-name='*)
                dict['app_name']="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict['app_name']="${2:?}"
                shift 2
                ;;
            '--pc-name='*)
                dict['pc_name']="${1#*=}"
                shift 1
                ;;
            '--pc-name')
                dict['pc_name']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--app-name' "${dict['app_name']}" \
        '--pc-name' "${dict['pc_name']}"
    dict['pc_file']="${dict['opt_prefix']}/${dict['app_name']}/lib/\
pkgconfig/${dict['pc_name']}.pc"
    koopa_assert_is_file "${dict['pc_file']}"
    dict['str']="$("${app['pkg_config']}" --modversion "${dict['pc_file']}")"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
