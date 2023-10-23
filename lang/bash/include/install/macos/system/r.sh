#!/usr/bin/env bash

main() {
    # """
    # Install R framework binary.
    # @note Updated 2023-10-23.
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
    local -A app bool dict
    local -a deps
    bool['backup']=0
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
    # > case "${dict['os']}" in
    # >     'sonoma' | \
    # >     'ventura' | \
    # >     'monterey' | \
    # >     'big-sur')
    # >         dict['os']='big-sur'
    # >         ;;
    # >     *)
    # >         koopa_stop 'Unsupported OS.'
    # >         ;;
    # > esac
    dict['os']='big-sur'
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['prefix']="${dict['framework_prefix']}/Versions/\
${dict['maj_min_ver']}-${dict['arch']}/Resources"
    [[ -d "${dict['prefix']}/site-library" ]] && bool['backup']=1
    if [[ "${bool['backup']}" -eq 1 ]]
    then
        koopa_alert "Backing up site library."
        koopa_mv "${dict['prefix']}/site-library" 'site-library'
    fi
    dict['url']="https://cran.r-project.org/bin/macosx/\
${dict['os']}-${dict['arch']}/base/R-${dict['version']}-${dict['arch']}.pkg"
    koopa_download "${dict['url']}"
    koopa_sudo \
        "${app['installer']}" \
            -pkg "$(koopa_basename "${dict['url']}")" \
            -target '/'
    koopa_assert_is_dir "${dict['prefix']}"
    if [[ "${bool['backup']}" -eq 1 ]]
    then
        koopa_alert "Restoring site library."
        koopa_mv 'site-library' "${dict['prefix']}/site-library"
    fi
    app['r']="${dict['prefix']}/bin/R"
    koopa_assert_is_installed "${app['r']}"
    koopa_macos_install_system_gfortran
    koopa_macos_install_system_xcode_openmp
    readarray -t deps <<< "$(koopa_app_dependencies 'r')"
    koopa_dl 'R dependencies' "$(koopa_to_string "${deps[@]}")"
    koopa_cli_install "${deps[@]}"
    koopa_configure_r "${app['r']}"
    return 0
}
