#!/usr/bin/env bash

koopa::r_link_site_library() { # {{{1
    # """
    # Link R site library.
    # @note Updated 2022-01-20.
    #
    # R on Fedora won't pick up site library in '--vanilla' mode unless we
    # symlink the site-library into '/usr/local/lib/R' as well.
    # Refer to '/usr/lib64/R/etc/Renviron' for configuration details.
    #
    # Changed to unversioned library approach at opt prefix in koopa v0.9.
    # """
    local app conf_args dict
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa::locate_r)"
    koopa::assert_is_installed "${app[r]}"
    declare -A dict=(
        [r_prefix]="$(koopa::r_prefix "${app[r]}")"
        [version]="$(koopa::r_version "${app[r]}")"
    )
    koopa::assert_is_dir "${dict[r_prefix]}"
    dict[lib_source]="$(koopa::r_packages_prefix "${dict[version]}")"
    dict[lib_target]="${dict[r_prefix]}/site-library"
    koopa::alert "Linking '${dict[lib_target]}' to '${dict[lib_source]}'."
    koopa::sys_mkdir "${dict[lib_source]}"
    if koopa::is_koopa_app "${app[r]}"
    then
        koopa::sys_ln "${dict[lib_source]}" "${dict[lib_target]}"
    else
        koopa::ln --sudo "${dict[lib_source]}" "${dict[lib_target]}"
    fi
    conf_args=(
        "--prefix=${dict[lib_source]}"
        '--name-fancy=R'
        '--name=r'
    )
    if [[ "${dict[version]}" == 'devel' ]]
    then
        conf_args+=(
            '--no-link'
        )
    fi
    koopa::configure_app_packages "${conf_args[@]}"
    if koopa::is_fedora && [[ -d '/usr/lib64/R' ]]
    then
        koopa::alert_note "Fixing Fedora R configuration at '/usr/lib64/R'."
        koopa::mkdir --sudo '/usr/lib64/R/site-library'
        koopa::ln --sudo \
            '/usr/lib64/R/site-library' \
            '/usr/local/lib/R/site-library'
    fi
    return 0
}
