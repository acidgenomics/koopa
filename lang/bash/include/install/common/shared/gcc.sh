#!/usr/bin/env bash

# FIXME Consider building this with full LLVM on macOS.

# FIXME This is still failing on my Intel MacBook, CLT 15.1.0.0.1.1696033181.
# FIXME Try building just fortran to see if we can reproduce faster.

# Potentially related to build error:
# https://opensource.apple.com/source/llvmgcc42/
# https://opensource.apple.com/source/llvmgcc42/llvmgcc42-2336.11/
# https://opensource.apple.com/source/llvmgcc42/llvmgcc42-2335.9/libgfortran/generated/maxloc1_16_r10.c
# https://opensource.apple.com/source/llvmgcc42/llvmgcc42-2336.11/libgfortran/generated/maxloc1_16_r16.c.auto.html

main() {
    # """
    # Install GCC.
    # @note Updated 2023-10-11.
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
    # Need to apply 'math.h' patch for macOS Sonoma CLT breaking changes.
    # See also:
    # - https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;
    #     h=93f803d53b5ccaabded9d7b4512b54da81c1c616
    # - https://github.com/Homebrew/homebrew-core/blob/
    #     57262c5e2233373537e8b32c00a2b03cec63e7a5/Formula/g/gcc.rb#L19
    # - https://github.com/Homebrew/brew/blob/master/Library/Homebrew/patch.rb
    # - https://www.gnu.org/software/diffutils/manual/html_node/
    #     Multiple-Patches.html
    # - fixincludes/fixincl.x
    #   https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;
    #     h=93f803d53b5ccaabded9d7b4512b54da81c1c616#patch1
    # - fixincludes/inclhack.def
    #   https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;
    #     h=93f803d53b5ccaabded9d7b4512b54da81c1c616#patch2
    # - fixincludes/tests/base/math.h
    #   https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;
    #     h=93f803d53b5ccaabded9d7b4512b54da81c1c616#patch3
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
    local -A app bool dict
    local -a conf_args langs
    koopa_activate_app --build-only 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['gmp']="$(koopa_app_prefix 'gmp')"
    dict['gnu_mirror']="$(koopa_gnu_mirror_url)"
    dict['jobs']="$(koopa_cpu_count)"
    dict['mpc']="$(koopa_app_prefix 'mpc')"
    dict['mpfr']="$(koopa_app_prefix 'mpfr')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    langs=(
        'c'
        'c++'
        'fortran'
        'objc'
        'obj-c++'
    )
    dict['langs']="$(koopa_paste0 --sep=',' "${langs[@]}")"
    conf_args=(
        '-v'
        "--enable-languages=${dict['langs']}"
        "--prefix=${dict['prefix']}"
        "--with-gmp=${dict['gmp']}"
        "--with-mpc=${dict['mpc']}"
        "--with-mpfr=${dict['mpfr']}"
    )
    if koopa_is_linux
    then
        conf_args+=(
            '--disable-multilib'
            '--enable-default-pie'
        )
    elif koopa_is_macos
    then
        app['patch']="$(koopa_locate_patch)"
        koopa_assert_is_executable "${app['patch']}"
        bool['homebrew_patch']=0
        koopa_is_aarch64 && bool['homebrew_patch']=1
        bool['math_h_patch']=0
        dict['clt_maj_ver']="$(koopa_macos_xcode_clt_major_version)"
        dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
        dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
        dict['maj_min_ver2']="${dict['maj_min_ver']//./-}"
        dict['patch_prefix']="$(koopa_patch_prefix)/macos/\
gcc/${dict['version']}"
        dict['sysroot']="$(koopa_macos_sdk_prefix)"
        koopa_assert_is_dir \
            "${dict['patch_prefix']}" \
            "${dict['sysroot']}"
        conf_args+=(
            "--with-sysroot=${dict['sysroot']}"
            '--with-system-zlib'
        )
        if [[ "${dict['clt_maj_ver']}" -ge 15 ]]
        then
            # > koopa_is_aarch64 && bool['math_h_patch']=1
            app['ld']="$(koopa_macos_locate_ld_classic)"
            koopa_assert_is_executable "${app['ld']}"
            conf_args+=("--with-ld=${app['ld']}")
        fi
    fi
    dict['url']="${dict['gnu_mirror']}/gcc/gcc-${dict['version']}/\
gcc-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    if koopa_is_macos && [[ "${bool['homebrew_patch']}" -eq 1 ]]
    then
        dict['patch_file']="${dict['patch_prefix']}/homebrew.diff"
        koopa_assert_is_file "${dict['patch_file']}"
        (
            koopa_cd 'src'
            "${app['patch']}" \
                --input="${dict['patch_file']}" \
                --strip=1 \
                --verbose
        )
    fi
    if koopa_is_macos && [[ "${bool['math_h_patch']}" -eq 1 ]]
    then
        dict['patch_file']="${dict['patch_prefix']}/math-h.diff"
        koopa_assert_is_file "${dict['patch_file']}"
        (
            koopa_cd 'src'
            "${app['patch']}" \
                --input="${dict['patch_file']}" \
                --strip=1 \
                --verbose
        )
    fi
    koopa_mkdir 'build'
    koopa_cd 'build'
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ../src/configure --help
    ../src/configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
