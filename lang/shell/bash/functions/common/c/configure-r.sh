#!/usr/bin/env bash

# FIXME Rework to keep site library inside of system R instead of linking
# into koopa.

koopa_configure_r() {
    # """
    # Update R configuration.
    # @note Updated 2022-07-19.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
        [system]=0
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    [[ -x "${app[r]}" ]] || return 1
    declare -A dict=(
        [name]='r'
    )
    ! koopa_is_koopa_app "${app[r]}" && dict[system]=1
    dict[r_prefix]="$(koopa_r_prefix "${app[r]}")"
    dict[site_library]="${dict[r_prefix]}/site-library"
    koopa_alert_configure_start "${dict[name]}" "${dict[r_prefix]}"
    koopa_assert_is_dir "${dict[r_prefix]}"
    koopa_r_link_files_in_etc "${app[r]}"
    case "${dict[system]}" in
        '0')
            koopa_r_link_site_library "${app[r]}"
            koopa_sys_set_permissions --recursive "${dict[site_library]}"
            ;;
        '1')
            koopa_mkdir --sudo "${dict[site_library]}"
            koopa_chmod --sudo '0777' "${dict[site_library]}"
            koopa_r_javareconf "${app[r]}"
            koopa_r_rebuild_docs "${app[r]}"
            ;;
    esac
    koopa_alert_configure_success "${dict[name]}" "${dict[r_prefix]}"
    return 0
}
