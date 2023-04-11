#!/usr/bin/env bash

# FIXME Install OpenMP for R automatically here.
# FIXME Can we install it to a custom location?

main() {
    # """
    # Install R framework binary.
    # @note Updated 2023-04-04.
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
    local -a files
    if [[ ! -f '/usr/local/include/omp.h' ]]
    then
        koopa_stop \
            "'libomp' is not installed." \
            "Run 'koopa install system openmp' to resolve."
    fi
    app['installer']="$(koopa_macos_locate_installer)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch)"
    dict['framework_prefix']='/Library/Frameworks/R.framework'
    dict['os']="$(koopa_kebab_case_simple "$(koopa_macos_os_codename)")"
    dict['url_stem']='https://cran.r-project.org/bin/macosx'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    case "${dict['arch']}" in
        'arm64')
            dict['maj_min_ver']="${dict['maj_min_ver']}-${dict['arch']}"
            ;;
    esac
    dict['prefix']="${dict['framework_prefix']}/Versions/\
${dict['maj_min_ver']}/Resources"
    case "${dict['arch']}" in
        'aarch64' | 'arm64')
            case "${dict['os']}" in
                'ventura' | \
                'monterey' | \
                'big-sur')
                    dict['os2']='big-sur'
                    ;;
                *)
                    koopa_stop 'Unsupported OS.'
                    ;;
            esac
            dict['arch2']='arm64'
            dict['pkg_file']="R-${dict['version']}-${dict['arch2']}.pkg"
            dict['url']="${dict['url_stem']}/${dict['os2']}-${dict['arch2']}/\
base/${dict['pkg_file']}"
            ;;
        'x86_64')
            dict['pkg_file']="R-${dict['version']}.pkg"
            dict['url']="${dict['url_stem']}/base/${dict['pkg_file']}"
            ;;
        *)
            koopa_stop "Unsupported architecture: '${dict['arch']}'."
            ;;
    esac
    koopa_download "${dict['url']}"
    "${app['sudo']}" "${app['installer']}" \
        -pkg "${dict['pkg_file']}" \
        -target '/'
    koopa_assert_is_dir "${dict['prefix']}"
    app['r']="${dict['prefix']}/bin/R"
    koopa_assert_is_installed "${app['r']}"
    koopa_configure_r "${app['r']}"
    files=(
        '/usr/local/include/fakemysql.h'
        '/usr/local/include/fakepq.h'
        '/usr/local/include/fakesql.h'
        '/usr/local/include/itcl.h'
        '/usr/local/include/itcl2TclOO.h'
        '/usr/local/include/itclDecls.h'
        '/usr/local/include/itclInt.h'
        '/usr/local/include/itclIntDecls.h'
        '/usr/local/include/itclMigrate2TclCore.h'
        '/usr/local/include/itclTclIntStubsFcn.h'
        '/usr/local/include/mysqlStubs.h'
        '/usr/local/include/odbcStubs.h'
        '/usr/local/include/pqStubs.h'
        '/usr/local/include/tcl.h'
        '/usr/local/include/tclDecls.h'
        '/usr/local/include/tclOO.h'
        '/usr/local/include/tclOODecls.h'
        '/usr/local/include/tclPlatDecls.h'
        '/usr/local/include/tclThread.h'
        '/usr/local/include/tclTomMath.h'
        '/usr/local/include/tclTomMathDecls.h'
        '/usr/local/include/tdbc.h'
        '/usr/local/include/tdbcDecls.h'
        '/usr/local/include/tdbcInt.h'
        '/usr/local/include/tk.h'
        '/usr/local/include/tkDecls.h'
        '/usr/local/include/tkPlatDecls.h'
        '/usr/local/lib/libtcl8.6.dylib'
        '/usr/local/lib/libtclstub8.6.a'
        '/usr/local/lib/libtk8.6.dylib'
        '/usr/local/lib/libtkstub8.6.a'
        '/usr/local/lib/pkgconfig/tcl.pc'
        '/usr/local/lib/pkgconfig/tk.pc'
    )
    koopa_rm --sudo "${files[@]}"
    return 0
}
