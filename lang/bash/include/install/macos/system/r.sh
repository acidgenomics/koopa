#!/usr/bin/env bash

# FIXME Back up the site packages library for point release updates.

main() {
    # """
    # Install R framework binary.
    # @note Updated 2023-04-25.
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
    local -A app dict
    app['installer']="$(koopa_macos_locate_installer)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch)"
    dict['framework_prefix']='/Library/Frameworks/R.framework'
    dict['os']="$(koopa_kebab_case "$(koopa_macos_os_codename)")"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    case "${dict['arch']}" in
        'aarch64')
            dict['arch']='arm64'
            ;;
    esac
    case "${dict['os']}" in
        'ventura' | \
        'monterey' | \
        'big-sur')
            dict['os']='big-sur'
            ;;
        *)
            koopa_stop 'Unsupported OS.'
            ;;
    esac
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['prefix']="${dict['framework_prefix']}/Versions/\
${dict['maj_min_ver']}-${dict['arch']}/Resources"
    dict['url']="https://cran.r-project.org/bin/macosx/\
${dict['os']}-${dict['arch']}/base/R-${dict['version']}-${dict['arch']}.pkg"
    koopa_download "${dict['url']}"
    koopa_sudo \
        "${app['installer']}" \
            -pkg "$(koopa_basename "${dict['url']}")" \
            -target '/'
    koopa_assert_is_dir "${dict['prefix']}"
    app['r']="${dict['prefix']}/bin/R"
    koopa_assert_is_installed "${app['r']}"
    koopa_macos_install_system_xcode_openmp
    koopa_configure_r "${app['r']}"
    return 0
}
