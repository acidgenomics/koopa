#!/usr/bin/env bash

koopa_configure_r() { # {{{1
    # """
    # Update R configuration.
    # @note Updated 2022-01-25.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # """
    local dict
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        [name_fancy]='R'
        [r]="${1:-}"
    )
    [[ -z "${dict[r]}" ]] && dict[r]="$(koopa_locate_r)"
    koopa_assert_is_installed "${dict[r]}"
    dict[r_prefix]="$(koopa_r_prefix "${dict[r]}")"
    koopa_alert_configure_start "${dict[name_fancy]}" "${dict[r_prefix]}"
    koopa_assert_is_dir "${dict[r_prefix]}"
    if koopa_is_koopa_app "${dict[r]}"
    then
        koopa_sys_set_permissions --recursive "${dict[r_prefix]}"
        # Ensure that (Debian) system 'etc' directories are removed.
        dict[make_prefix]="$(koopa_make_prefix)"
        dict[etc_prefix1]="${dict[make_prefix]}/lib/R/etc"
        dict[etc_prefix2]="${dict[make_prefix]}/lib64/R/etc"
        if [[ -d "${dict[etc_prefix1]}" ]] && [[ ! -L "${dict[etc_prefix1]}" ]]
        then
            koopa_sys_rm "${dict[etc_prefix1]}"
        fi
        if [[ -d "${dict[etc_prefix2]}" ]] && [[ ! -L "${dict[etc_prefix2]}" ]]
        then
            koopa_sys_rm "${dict[etc_prefix2]}"
        fi
    else
        koopa_sys_set_permissions --recursive "${dict[r_prefix]}/library"
    fi
    koopa_r_link_files_into_etc "${dict[r]}"
    koopa_r_link_site_library "${dict[r]}"
    koopa_r_javareconf "${dict[r]}"
    koopa_r_rebuild_docs "${dict[r]}"
    koopa_sys_set_permissions --recursive "${dict[r_prefix]}/site-library"
    koopa_alert_configure_success "${dict[name_fancy]}" "${dict[r_prefix]}"
    return 0
}
