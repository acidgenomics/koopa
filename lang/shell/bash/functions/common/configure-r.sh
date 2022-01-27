#!/usr/bin/env bash

koopa::configure_r() { # {{{1
    # """
    # Update R configuration.
    # @note Updated 2022-01-25.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # """
    local dict
    koopa::assert_has_args_le "$#" 1
    declare -A dict=(
        [name_fancy]='R'
        [r]="${1:-}"
    )
    [[ -z "${dict[r]}" ]] && dict[r]="$(koopa::locate_r)"
    koopa::assert_is_installed "${dict[r]}"
    dict[r_prefix]="$(koopa::r_prefix "${dict[r]}")"
    koopa::alert_configure_start "${dict[name_fancy]}" "${dict[r_prefix]}"
    koopa::assert_is_dir "${dict[r_prefix]}"
    if koopa::is_koopa_app "${dict[r]}"
    then
        koopa::sys_set_permissions --recursive "${dict[r_prefix]}"
        # Ensure that (Debian) system 'etc' directories are removed.
        dict[make_prefix]="$(koopa::make_prefix)"
        dict[etc_prefix1]="${dict[make_prefix]}/lib/R/etc"
        dict[etc_prefix2]="${dict[make_prefix]}/lib64/R/etc"
        if [[ -d "${dict[etc_prefix1]}" ]] && [[ ! -L "${dict[etc_prefix1]}" ]]
        then
            koopa::sys_rm "${dict[etc_prefix1]}"
        fi
        if [[ -d "${dict[etc_prefix2]}" ]] && [[ ! -L "${dict[etc_prefix2]}" ]]
        then
            koopa::sys_rm "${dict[etc_prefix2]}"
        fi
    else
        koopa::sys_set_permissions --recursive "${dict[r_prefix]}/library"
    fi
    koopa::r_link_files_into_etc "${dict[r]}"
    koopa::r_link_site_library "${dict[r]}"
    koopa::r_javareconf "${dict[r]}"
    koopa::r_rebuild_docs "${dict[r]}"
    koopa::sys_set_permissions --recursive "${dict[r_prefix]}/site-library"
    koopa::alert_configure_success "${dict[name_fancy]}" "${dict[r_prefix]}"
    return 0
}
