#!/usr/bin/env bash

main() {
    # """
    # Install HDF5.
    # @note Updated 2023-04-06.
    #
    # Using gcc here for gfortran.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make'
    koopa_activate_app 'zlib' 'gcc'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='hdf5'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://support.hdfgroup.org/ftp/HDF5/releases/\
${dict['name']}-${dict['maj_min_ver']}/${dict['name']}-${dict['version']}/\
src/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-build-mode=production'
        '--enable-cxx'
        '--enable-fortran'
        "--with-zlib=${dict['zlib']}"
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    # > "${app['make']}" check
    "${app['make']}" install
    return 0
}
