#!/usr/bin/env bash

# FIXME Rework using app/dict approach.
koopa::r_link_site_library() { # {{{1
    # """
    # Link R site library.
    # @note Updated 2021-06-16.
    #
    # R on Fedora won't pick up site library in '--vanilla' mode unless we
    # symlink the site-library into '/usr/local/lib/R' as well.
    # Refer to '/usr/lib64/R/etc/Renviron' for configuration details.
    #
    # Changed to unversioned library approach at opt prefix in koopa v0.9.
    # """
    local conf_args lib_source lib_target r r_prefix version
    koopa::assert_has_args_le "$#" 1
    r="${1:-}"
    [[ -z "$r" ]] && r="$(koopa::locate_r)"
    koopa::assert_is_installed "$r"
    r_prefix="$(koopa::r_prefix "$r")"
    koopa::assert_is_dir "$r_prefix"
    version="$(koopa::r_version "$r")"
    lib_source="$(koopa::r_packages_prefix "$version")"
    lib_target="${r_prefix}/site-library"
    koopa::alert "Linking '${lib_target}' to '${lib_source}'."
    koopa::sys_mkdir "$lib_source"
    if koopa::is_koopa_app "$r"
    then
        koopa::sys_ln "$lib_source" "$lib_target"
    else
        koopa::ln --sudo "$lib_source" "$lib_target"
    fi
    conf_args=(
        "--prefix=${lib_source}"
        '--name-fancy=R'
        '--name=r'
    )
    if [[ "$version" == 'devel' ]]
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
