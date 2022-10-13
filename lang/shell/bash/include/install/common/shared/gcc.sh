#!/usr/bin/env bash

# FIXME This currently fails to build with Xcode CLT 14
# https://github.com/iains/gcc-12-branch/issues/6

main() {
    # """
    # Install GCC.
    # @note Updated 2022-10-01.
    #
    # Do not run './configure' from within the source directory.
    # Instead, you need to run configure from outside the source directory,
    # in a separate directory created for the build.
    #
    # Prerequisites:
    #
    # If you do not have the GMP, MPFR and MPC support libraries already
    # installed as part of your operating system then there are two simple ways
    # to proceed, and one difficult, error-prone way. For some reason most
    # people choose the difficult way. The easy ways are:
    #
    # If it provides sufficiently recent versions, use your OS package
    # management system to install the support libraries in standard system
    # locations.
    #
    # For Debian-based systems, including Ubuntu, you should install:
    # - libgmp-dev
    # - libmpc-dev
    # - libmpfr-dev
    #
    # For RPM-based systems, including Fedora and SUSE, you should install:
    # - gmp-devel
    # - libmpc-devel (or mpc-devel on SUSE)
    # - mpfr-devel
    #
    # The packages will install the libraries and headers in standard system
    # directories so they can be found automatically when building GCC.
    #
    # Alternatively, after extracting the GCC source archive, simply run the
    # './contrib/download_prerequisites' script in the GCC source directory.
    # That will download the support libraries and create symlinks, causing
    # them to be built automatically as part of the GCC build process.
    # Set 'GRAPHITE_LOOP_OPT=no' in the script if you want to build GCC without
    # ISL, which is only needed for the optional Graphite loop optimizations. 
    #
    # The difficult way, which is not recommended, is to download the sources
    # for GMP, MPFR and MPC, then configure and install each of them in
    # non-standard locations.
    #
    # @seealso
    # - https://ftp.gnu.org/gnu/gcc/
    # - https://gcc.gnu.org/install/
    # - https://gcc.gnu.org/install/prerequisites.html
    # - https://gcc.gnu.org/wiki/InstallingGCC
    # - https://gcc.gnu.org/wiki/FAQ
    # - https://github.com/fxcoudert/gfortran-for-macOS/blob/
    #     master/build_package.md
    # - https://solarianprogrammer.com/2019/10/12/compiling-gcc-macos/
    # - https://solarianprogrammer.com/2016/10/07/building-gcc-ubuntu-linux/
    # - https://medium.com/@darrenjs/building-gcc-from-source-dcc368a3bb70
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app \
        'gmp' \
        'mpfr' \
        'mpc'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['gmp']="$(koopa_app_prefix 'gmp')"
        ['gnu_mirror']="$(koopa_gnu_mirror_url)"
        ['jobs']="$(koopa_cpu_count)"
        ['mpc']="$(koopa_app_prefix 'mpc')"
        ['mpfr']="$(koopa_app_prefix 'mpfr')"
        ['name']='gcc'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['gmp']}" \
        "${dict['mpc']}" \
        "${dict['mpfr']}"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="${dict['gnu_mirror']}/${dict['name']}/\
${dict['name']}-${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    # Need to build outside of source code directory.
    koopa_mkdir 'build'
    koopa_cd 'build'
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-multilib'
        '--enable-checking=release'
        '--enable-languages=c,c++,fortran,objc,obj-c++'
        "--with-gmp=${dict['gmp']}"
        "--with-mpc=${dict['mpc']}"
        "--with-mpfr=${dict['mpfr']}"
        '-v'
    )
    if koopa_is_macos
    then
        app['uname']="$(koopa_locate_uname --allow-system)"
        [[ -x "${app['uname']}" ]] || return 1
        # e.g. '21.4.0' for macOS 12.3.1.
        dict['kernel_version']="$("${app['uname']}" -r)"
        dict['kernel_maj_ver']="$( \
            koopa_major_version "${dict['kernel_version']}" \
        )"
        dict['sdk_prefix']="$(koopa_macos_sdk_prefix)"
        conf_args+=(
            "--build=${dict['arch']}-apple-darwin${dict['kernel_maj_ver']}"
            '--disable-multilib'
            '--with-native-system-header-dir=/usr/include'
            "--with-sysroot=${dict['sdk_prefix']}"
        )
    fi
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    "../${dict['name']}-${dict['version']}/configure" --help
    "../${dict['name']}-${dict['version']}/configure" "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
