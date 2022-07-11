#!/usr/bin/env bash

# FIXME Hitting this on macOS, need to rework.
# chmod: Unable to change file mode on /opt/koopa/app/r/4.2.1/lib/R/etc/Makevars.site: Operation not permitted

koopa_configure_r() {
    # """
    # Update R configuration.
    # @note Updated 2022-07-11.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    declare -A dict=(
        [name_fancy]='R'
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    koopa_assert_is_installed "${app[r]}"
    dict[r_prefix]="$(koopa_r_prefix "${app[r]}")"
    koopa_alert_configure_start "${dict[name_fancy]}" "${dict[r_prefix]}"
    koopa_assert_is_dir "${dict[r_prefix]}"
    koopa_r_link_files_in_etc "${app[r]}"
    koopa_r_link_site_library "${app[r]}"
    koopa_r_makevars "${app[r]}"
    koopa_r_javareconf "${app[r]}"
    koopa_r_rebuild_docs "${app[r]}"
    koopa_sys_set_permissions --recursive "${dict[r_prefix]}/site-library"
    koopa_alert_configure_success "${dict[name_fancy]}" "${dict[r_prefix]}"
    return 0
}
