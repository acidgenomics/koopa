#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install R framework binary.
    # @note Updated 2022-03-30.
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
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [installer]="$(koopa_macos_locate_installer)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [framework_prefix]='/Library/Frameworks/R.framework'
        [os]="$(koopa_kebab_case_simple "$(koopa_os_codename)")"
        [url_stem]='https://cran.r-project.org/bin/macosx'
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_min_version]="$(koopa_major_minor_version "${dict[version]}")"
    dict[prefix]="${dict[framework_prefix]}/Versions/${dict[maj_min_version]}"
    case "${dict[arch]}" in
        'aarch64')
            dict[arch2]='arm64'
            dict[pkg_file]="R-${dict[version]}-${dict[arch2]}.pkg"
            dict[url]="${dict[url_stem]}/${dict[os]}-${dict[arch2]}/\
base/${dict[pkg_file]}"
            ;;
        'x86_64')
            dict[pkg_file]="R-${dict[version]}.pkg"
            dict[url]="${dict[url_stem]}/base/${dict[pkg_file]}"
            ;;
        *)
            koopa_stop "Unsupported architecture: '${dict[arch]}'."
            ;;
    esac
    koopa_download "${dict[url]}"
    "${app[sudo]}" "${app[installer]}" -pkg "${dict[pkg_file]}" -target '/'
    koopa_assert_is_dir "${dict[prefix]}"
    app[r]="${dict[prefix]}/bin/R"
    koopa_assert_is_installed "${app[r]}"
    koopa_configure_r "${app[r]}"
    return 0
}
