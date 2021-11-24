#!/usr/bin/env bash

koopa:::install_gcc() { # {{{1
    # """
    # Install GCC.
    # @note Updated 2021-11-24.
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
    # - https://solarianprogrammer.com/2016/10/07/building-gcc-ubuntu-linux/
    # - https://medium.com/@darrenjs/building-gcc-from-source-dcc368a3bb70
    # """
    local app conf_args dict
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [gnu_mirror]="$(koopa::gnu_mirror_url)"
        [jobs]="$(koopa::cpu_count)"
        [name]='gcc'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="${dict[gnu_mirror]}/${dict[name]}/\
${dict[name]}-${dict[version]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    # Need to build outside of source code directory.
    koopa::mkdir 'build'
    koopa::cd 'build'
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-multilib'
        '--enable-languages=c,c++,fortran'
        '--enable-checking=release'
        '-v'
    )
    if koopa::is_macos
    then
        dict[mac_ver]="$(koopa::macos_os_version)"
        dict[mac_maj_min_ver]="$(koopa::major_minor_version "${dict[mac_ver]}")"
        dict[sdk_prefix]='/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk'
        conf_args+=(
            "--build=${dict[arch]}-apple-darwin${dict[mac_maj_min_ver]}"
            "--with-native-system-header-dir=${dict[sdk_prefix]}/usr/include"
            # Workaround for Xcode 12.5 bug on Intel.
            # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=100340
            '--without-build-config'
        )
    fi
    "../${dict[name]}-${dict[version]}/configure" "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
