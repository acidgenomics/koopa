#!/usr/bin/env bash

# FIXME Now seeing a build error on macOS Sonoma:
# ld: unknown options: -commons
# clang: error: linker command failed with exit code 1 (use -v to see invocation)
# gmake[2]: *** [Makefile:1497: H5detect] Error 1
# gmake[2]: *** Waiting for unfinished jobs....
# ld: unknown options: -commons
# clang: error: linker command failed with exit code 1 (use -v to see invocation)
# gmake[2]: *** [Makefile:1501: H5make_libsettings] Error 1
# gmake[2]: Leaving directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/tmp.5Qp6kHf58q/src/src'
# gmake[1]: *** [Makefile:1360: all] Error 2
# gmake[1]: Leaving directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/tmp.5Qp6kHf58q/src/src'
# gmake: *** [Makefile:729: all-recursive] Error 1

# Related issue:
# https://community.intel.com/t5/Intel-Fortran-Compiler/Mac-Xcode-15-0-unknown-options-commons/td-p/1526357

main() {
    # """
    # Install HDF5.
    # @note Updated 2023-10-04.
    #
    # Using gcc here for gfortran.
    #
    # @seealso
    # - https://www.hdfgroup.org/downloads/hdf5/source-code/
    # - https://docs.hdfgroup.org/archive/support/HDF5/release/cmakebuild.html
    # - https://docs.hdfgroup.org/archive/support/HDF5/release/chgcmkbuild.html
    # - https://github.com/conda-forge/hdf5-feedstock
    # - https://formulae.brew.sh/formula/hdf5
    # - https://github.com/mokus0/bindings-hdf5/blob/master/doc/hdf5.pc
    # """
    local -A dict
    local -a conf_args deps
    deps=('zlib' 'gcc' 'libaec')
    koopa_activate_app "${deps[@]}"
    dict['libaec']="$(koopa_app_prefix 'libaec')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['mmp_ver']="$(koopa_major_minor_patch_version "${dict['version']}")"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        '--enable-build-mode=production'
        '--enable-cxx'
        '--enable-fortran'
        "--prefix=${dict['prefix']}"
        "--with-szlib=${dict['libaec']}"
        "--with-zlib=${dict['zlib']}"
    )
    if koopa_is_macos
    then
        # Work around incompatibility with new linker (FB13194355).
        # https://github.com/HDFGroup/hdf5/issues/3571
        LDFLAGS="${LDFLAGS:-}"
        LDFLAGS="-Wl,-ld_classic ${LDFLAGS}"
        export LDFLAGS
    fi
    dict['url']="https://support.hdfgroup.org/ftp/HDF5/releases/\
hdf5-${dict['maj_min_ver']}/hdf5-${dict['mmp_ver']}/src/\
hdf5-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    # Create pkg-config file.
    dict['pkg_config_file']="${dict['prefix']}/lib/pkgconfig/hdf5.pc"
    read -r -d '' "dict[pkg_config_string]" << END || true
prefix=${dict['prefix']}
exec_prefix=\${prefix}
bindir=\${exec_prefix}/bin
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: hdf5
Description: HDF5 library
Version: ${dict['version']}

Requires.private: zlib
Libs: -L\${libdir} -lhdf5
Cflags: -I\${includedir}
END
    if [[ ! -f "${dict['pkg_config_file']}" ]]
    then
        koopa_alert 'Adding pkg-config support.'
        koopa_write_string \
            --file="${dict['pkg_config_file']}" \
            --string="${dict['pkg_config_string']}"
    fi
    return 0
}
