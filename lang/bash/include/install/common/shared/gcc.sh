#!/usr/bin/env bash

# libgfortran build error on macOS Sonoma x86:
#
# ../../../src/libgfortran/generated/maxval_r10.c: In function 'maxval_r10':
# ./kinds.h:61:26: error: 'l' undeclared (first use in this function)
#    61 | #define GFC_REAL_10_HUGE l
#
# gmake[2]: *** [Makefile:1693: all] Error 2
# gmake[1]: *** [Makefile:20211: all-target-libgfortran] Error 2
# gmake: *** [Makefile:1079: all] Error 2

main() {
    # """
    # Install GCC.
    # @note Updated 2023-10-08.
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
    # - https://gcc.gnu.org/onlinedocs/gcc/Environment-Variables.html
    # - https://formulae.brew.sh/formula/gcc
    # - https://ports.macports.org/port/gcc13/
    # - https://github.com/fxcoudert/gfortran-for-macOS/blob/
    #     master/build_package.md
    # - https://solarianprogrammer.com/2019/10/12/compiling-gcc-macos/
    # - https://solarianprogrammer.com/2016/10/07/building-gcc-ubuntu-linux/
    # - https://medium.com/@darrenjs/building-gcc-from-source-dcc368a3bb70
    # - How to ensure @rpath gets baked correctly:
    #   https://www.linuxquestions.org/questions/linux-software-2/
    #     compiling-gcc-not-baking-rpath-correctly-4175661913/
    # """
    local -A app dict
    local -a build_deps conf_args deps langs
    build_deps=('make')
    deps=('gmp' 'mpfr' 'mpc' 'isl' 'zstd')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['gmp']="$(koopa_app_prefix 'gmp')"
    dict['gnu_mirror']="$(koopa_gnu_mirror_url)"
    dict['isl']="$(koopa_app_prefix 'isl')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['mpc']="$(koopa_app_prefix 'mpc')"
    dict['mpfr']="$(koopa_app_prefix 'mpfr')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zstd']="$(koopa_app_prefix 'zstd')"
    dict['boot_ldflags']="-static-libstdc++ -static-libgcc ${LDFLAGS:?}"
    langs=(
        'c'
        'c++'
        'objc'
        'obj-c++'
        'fortran'
    )
    dict['langs']="$(koopa_paste0 --sep=',' "${langs[@]}")"
    conf_args=(
        # Can also define here:
        # - '--disable-tls'
        # - "--libiconv-prefix=XXX"
        # - "--program-suffix=-mp-${major}"
        # - "--with-ar=XXX"
        # - "--with-as=XXX"
        # - "--with-bugurl=XXX"
        # - "--with-ld=XXX"
        '-v'
        '--disable-nls'
        '--enable-checking=release'
        '--enable-host-shared'
        # Avoiding building:
        #  - Ada and D, which require a pre-existing GCC to bootstrap
        #  - Go, currently not supported on macOS
        #  - BRIG
        # Consider adding 'jit' here, which is set in MacPorts.
        "--enable-languages=${dict['langs']}"
        '--enable-libstdcxx-time'
        # FIXME Is this causing libgfortran failure on macOS x86?
        # > '--enable-lto'
        "--prefix=${dict['prefix']}"
        '--with-build-config=bootstrap-debug'
        '--with-gcc-major-version-only'
        # Required dependencies.
        "--with-gmp=${dict['gmp']}"
        "--with-mpc=${dict['mpc']}"
        "--with-mpfr=${dict['mpfr']}"
        # Optional dependencies.
        "--with-isl=${dict['isl']}"
        "--with-zstd=${dict['zstd']}"
        # Ensure linkage is defined during bootstrap (stage 2).
        "--with-boot-ldflags=${dict['boot_ldflags']}"
    )
    if koopa_is_linux
    then
        conf_args+=(
            # Fix Linux error: gnu/stubs-32.h: No such file or directory.
            '--disable-multilib'
            # Enable to PIE by default to match what the host GCC uses.
            '--enable-default-pie'
        )
    elif koopa_is_macos
    then
        dict['sysroot']="$(koopa_macos_sdk_prefix)"
        koopa_assert_is_dir "${dict['sysroot']}"
        conf_args+=(
            '--with-native-system-header-dir=/usr/include'
            "--with-sysroot=${dict['sysroot']}"
            '--with-system-zlib'
        )
    fi
    if koopa_is_macos && koopa_is_aarch64
    then
        dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
        dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
        dict['maj_min_ver2']="${dict['maj_min_ver']//./-}"
        dict['url']="https://github.com/iains/gcc-${dict['maj_ver']}-branch/\
archive/refs/heads/gcc-${dict['maj_min_ver2']}-darwin.tar.gz"
        # Alternate URL:
        # > dict['url']="https://github.com/iains/gcc-${dict['maj_ver']}-\
        # > branch/archive/refs/tags/gcc-${dict['maj_min_ver']}-\
        # > darwin-r0.tar.gz"
    else
        dict['url']="${dict['gnu_mirror']}/gcc/gcc-${dict['version']}/\
gcc-${dict['version']}.tar.xz"
    fi
    # FIXME Only do this for clang 15+.
    if koopa_is_macos
    then
        app['ld']='/Library/Developer/CommandLineTools/usr/bin/ld-classic'
        koopa_assert_is_executable "${app['ld']}"
        # Can use '--with-system-zlib' here instead.
        conf_args+=("--with-ld=${app['ld']}")
    fi
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_mkdir 'build'
    koopa_cd 'build'
    unset -v LIBRARY_PATH
    koopa_print_env
    ../src/configure --help
    ../src/configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
