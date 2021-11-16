#!/usr/bin/env bash

# FIXME Need to remove the prefix if defined.
# FIXME Need to rethink the version handling?
# FIXME Need to define /usr/local/gfortran as a prefix?

koopa::macos_install_r_cran_gfortran() { # {{{1
    koopa:::install_app \
        --name-fancy='R CRAN gfortran' \
        --name='r-cran-gfortran' \
        --platform='macos' \
        --prefix="$(koopa::macos_gfortran_prefix)" \
        --system \
        --version="$(koopa::variable 'r-cran-gfortran')" \
        "$@"
}

# FIXME Need to support '--prefix' pathrough here with '--system' flag.

koopa::macos_uninstall_r_cran_gfortran() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='R CRAN gfortran' \
        --name='r-cran-gfortran' \
        --platform='macos' \
        --prefix="$(koopa::macos_gfortran_prefix)" \
        --system \
        "$@"
}

# FIXME Ensure we still support version here.
# FIXME Need to convert to wrapper.
# FIXME Reinstall may need to use '--sudo' here in system call.
# FIXME Ensure that when prefix is defined and '--reinstall' is not declared,
#       the install script errors.

koopa:::macos_install_r_cran_gfortran() { # {{{1
    # """
    # Install CRAN gfortran.
    # @note Updated 2021-11-16.
    # @seealso
    # - https://mac.r-project.org/tools/
    # - https://github.com/fxcoudert/gfortran-for-macOS/
    # """
    local dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [hdiutil]="$(koopa::macos_locate_hdiutil)"
        [installer]="$(koopa::macos_locate_installer)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [make_prefix]="$(koopa::make_prefix)"
        [name]='gfortran'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    case "${dict[arch]}" in
        'aarch64')
            dict[arch2]='ARM'
            ;;
        'x86_64')
            dict[arch2]='Intel'
            ;;
        *)
            koopa::stop "Unsupported architecture: '${dict[arch]}'."
            ;;
    esac
    dict[url_stem]="https://github.com/fxcoudert/gfortran-for-macOS/\
releases/download"
    case "${dict[version]}" in
        '8.2')
            # R 4.0, 4.1.
            dict[os]='Mojave'
            dict[file_stem]="${dict[name]}-${dict[version]}-${dict[os]}"
            dict[dmg_file]="${dict[file_stem]}.dmg"
            dict[url]="${dict[url_stem]}/${dict[version]}/${dict[dmg_file]}"
            dict[pkg_file]="/Volumes/${dict[file_stem]}/${dict[file_stem]}/\
${dict[name]}.pkg"
            ;;
        '10.2')
            # Not yet used, still in development.
            dict[os]="BigSur-${dict[arch2]}"
            dict[os2]="$(koopa::lowercase "${dict[os]}")"
            dict[file_stem]="${dict[name]}-${dict[version]}-${dict[os]}"
            dict[dmg_file]="${dict[file_stem]}.dmg"
            dict[url]="${dict[url_stem]}/${dict[version]}-${dict[os2]}/\
${dict[dmg_file]}"
            dict[pkg_file]="/Volumes/${dict[file_stem]}/${dict[name]}.pkg"
            ;;
        *)
            koopa::stop "Unsupported version: '${dict[version]}'."
    esac
    dict[mount_point]="/Volumes/${dict[file_stem]}"
    koopa::download "${dict[url]}" "${dict[dmg_file]}"
    "${app[hdiutil]}" mount "${dict[dmg_file]}"
    koopa::assert_is_file "${dict[pkg_file]}"
    "${app[sudo]}" "${app[installer]}" -pkg "${dict[pkg_file]}" -target '/'
    "${app[hdiutil]}" unmount "${dict[mount_point]}"
    koopa::assert_is_dir "${dict[prefix]}"
    # Ensure the installer doesn't link outside of target prefix.
    app[gfortran]="${dict[make_prefix]}/bin/${dict[name]}"
    if [[ -x "${app[gfortran]}" ]]
    then
        koopa::rm --sudo "${app[gfortran]}"
    fi
    return 0
}

koopa:::macos_uninstall_r_cran_gfortran() { # {{{1
    # """
    # Uninstall R CRAN gfortran.
    # @note Updated 2021-10-30.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [prefix]="${UNINSTALL_PREFIX:?}"
    )
    koopa::rm --sudo "${dict[prefix]}"
    return 0
}
