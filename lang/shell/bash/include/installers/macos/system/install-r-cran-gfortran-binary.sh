#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install CRAN gfortran binary.
    # @note Updated 2021-11-16.
    #
    # @seealso
    # - https://mac.r-project.org/tools/
    # - https://github.com/fxcoudert/gfortran-for-macOS/
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [hdiutil]="$(koopa_macos_locate_hdiutil)"
        [installer]="$(koopa_macos_locate_installer)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [make_prefix]="$(koopa_make_prefix)"
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
            koopa_stop "Unsupported architecture: '${dict[arch]}'."
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
            dict[os2]="$(koopa_lowercase "${dict[os]}")"
            dict[file_stem]="${dict[name]}-${dict[version]}-${dict[os]}"
            dict[dmg_file]="${dict[file_stem]}.dmg"
            dict[url]="${dict[url_stem]}/${dict[version]}-${dict[os2]}/\
${dict[dmg_file]}"
            dict[pkg_file]="/Volumes/${dict[file_stem]}/${dict[name]}.pkg"
            ;;
        *)
            koopa_stop "Unsupported version: '${dict[version]}'."
    esac
    dict[mount_point]="/Volumes/${dict[file_stem]}"
    koopa_download "${dict[url]}" "${dict[dmg_file]}"
    "${app[hdiutil]}" mount "${dict[dmg_file]}"
    koopa_assert_is_file "${dict[pkg_file]}"
    "${app[sudo]}" "${app[installer]}" -pkg "${dict[pkg_file]}" -target '/'
    "${app[hdiutil]}" unmount "${dict[mount_point]}"
    koopa_assert_is_dir "${dict[prefix]}"
    # Ensure the installer doesn't link outside of target prefix.
    app[gfortran]="${dict[make_prefix]}/bin/${dict[name]}"
    if [[ -x "${app[gfortran]}" ]]
    then
        koopa_rm --sudo "${app[gfortran]}"
    fi
    return 0
}
