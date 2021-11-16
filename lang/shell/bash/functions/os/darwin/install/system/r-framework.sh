#!/usr/bin/env bash

koopa::macos_install_r_framework() { # {{{1
    koopa:::install_app \
        --installer='r-framework' \
        --name-fancy='R framework' \
        --name='r' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_uninstall_r_framework() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='R framework' \
        --name='r' \
        --platform='macos' \
        --system \
        --uninstaller='r-framework' \
        "$@"
}

koopa:::macos_install_r_framework() { # {{{1
    # """
    # Install R framework.
    # @note Updated 2021-11-04.
    #
    # @section Intel:
    #
    # Important: this release uses Xcode 12.4 and GNU Fortran 8.2. If you wish
    # to compile R packages from sources, you may need to download GNU Fortran
    # 8.2 - see the tools directory.
    #
    # @section ARM:
    #
    # This release uses Xcode 12.4 and experimental GNU Fortran 11 arm64 fork.
    # If you wish to compile R packages from sources, you may need to download
    # GNU Fortran for arm64 from https://mac.R-project.org/libs-arm64. Any
    # external libraries and tools are expected to live in /opt/R/arm64 to not
    # conflict with Intel-based software and this build will not use /usr/local
    # to avoid such conflicts.
    #
    # @seealso
    # - https://cran.r-project.org/bin/macosx/
    # - https://mac.r-project.org/tools/
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [installer]="$(koopa::macos_locate_installer)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [framework_prefix]='/Library/Frameworks/R.framework'
        [os]="$(koopa::kebab_case_simple "$(koopa::os_codename)")"
        [url_stem]='https://cran.r-project.org/bin/macosx'
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_min_version]="$(koopa::major_minor_version "${dict[version]}")"
    dict[prefix]="${dict[framework_prefix]}/Versions/${dict[maj_min_version]}"
    case "${dict[arch]}" in
        'aarch64')
            dict[arch2]='arm64'
            dict[pkg_file]="R-${dict[version]}-${dict[arch2]}.pkg"
            dict[url]="${dict[url_stem]}/${dict[os]}-${dict[arch2]}/\
base/${dict[pkg_file]}"
            ;;
        'x86_64')
            dict[pkg_file]="R-${version}.pkg"
            dict[url]="${dict[url_stem]}/base/${dict[pkg_file]}"
            ;;
        *)
            koopa::stop "Unsupported architecture: '${dict[arch]}'."
            ;;
    esac
    koopa::download "${dict[url]}"
    "${app[sudo]}" "${app[installer]}" -pkg "${dict[pkg_file]}" -target '/'
    koopa::assert_is_dir "${dict[prefix]}"
    return 0
}

koopa:::macos_uninstall_r_framework() { # {{{1
    # """
    # Uninstall R framework.
    # @note Updated 2021-11-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::rm --sudo \
        '/Applications/R.app' \
        '/Library/Frameworks/R.framework'
    koopa::delete_broken_symlinks '/usr/local/bin'
    return 0
}
