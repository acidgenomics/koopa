#!/usr/bin/env bash

koopa_r_link_site_library() {
    # """
    # Link R site library.
    # @note Updated 2022-04-04.
    #
    # R on Fedora won't pick up site library in '--vanilla' mode unless we
    # symlink the site-library into '/usr/local/lib/R' as well.
    # Refer to '/usr/lib64/R/etc/Renviron' for configuration details.
    #
    # Changed to unversioned library approach at opt prefix in koopa v0.9.
    # """
    local app conf_args dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    koopa_assert_is_installed "${app[r]}"
    declare -A dict=(
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
        [version]="$(koopa_r_version "${app[r]}")"
    )
    koopa_assert_is_dir "${dict[r_prefix]}"
    dict[lib_source]="$(koopa_r_packages_prefix "${dict[version]}")"
    dict[lib_target]="${dict[r_prefix]}/site-library"
    koopa_alert "Linking '${dict[lib_target]}' to '${dict[lib_source]}'."
    koopa_sys_mkdir "${dict[lib_source]}"
    if koopa_is_koopa_app "${app[r]}"
    then
        koopa_sys_ln "${dict[lib_source]}" "${dict[lib_target]}"
    else
        koopa_ln --sudo "${dict[lib_source]}" "${dict[lib_target]}"
    fi
    conf_args=(
        '--name-fancy=R'
        '--name=r'
        "--prefix=${dict[lib_source]}"
    )
    if [[ "${dict[version]}" == 'devel' ]]
    then
        conf_args+=('--no-link-in-opt')
    fi
    koopa_configure_app_packages "${conf_args[@]}"
    if koopa_is_fedora && [[ -d '/usr/lib64/R' ]]
    then
        koopa_alert_note "Fixing Fedora R configuration at '/usr/lib64/R'."
        koopa_mkdir --sudo '/usr/lib64/R/site-library'
        koopa_ln --sudo \
            '/usr/lib64/R/site-library' \
            '/usr/local/lib/R/site-library'
    fi
    return 0
}
