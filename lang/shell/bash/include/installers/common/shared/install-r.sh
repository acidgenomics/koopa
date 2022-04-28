#!/usr/bin/env bash

# FIXME gert package is failing to install from source on macOS:
#
# Error: package or namespace load failed for ‘gert’ in dyn.load(file, DLLpath = DLLpath, ...):
#  unable to load shared object '/opt/koopa/app/r-packages/devel/00LOCK-gert/00new/gert/libs/gert.so':
#   dlopen(/opt/koopa/app/r-packages/devel/00LOCK-gert/00new/gert/libs/gert.so, 0x0006): Symbol not found: _deflate
#   Referenced from: /opt/koopa/app/libssh2/1.10.0/lib/libssh2.1.dylib
#   Expected in: /opt/koopa/app/openssl/3.0.2/lib/libcrypto.3.dylib
# Error: loading failed
# Execution halted
# ERROR: loading failed
# * removing ‘/opt/koopa/app/r-packages/devel/gert’
# Warning in install.packages("gert") :
#   installation of package ‘gert’ had non-zero exit status

main() { # {{{1
    # """
    # Install R.
    # @note Updated 2022-04-26.
    #
    # @section gfortran configuration on macOS:
    #
    # fxcoudert's gfortran works more reliably than using Homebrew gcc
    # See also:
    # - https://mac.r-project.org
    # - https://github.com/fxcoudert/gfortran-for-macOS/releases
    # - https://developer.r-project.org/Blog/public/2020/11/02/
    #     will-r-work-on-apple-silicon/index.html
    # - https://bugs.r-project.org/bugzilla/show_bug.cgi?id=18024
    #
    # @section Recommended Debian packages (for Dockerfile):
    #
    # - 'bash-completion'
    # - 'bison'
    # - 'debhelper'
    # - 'default-jdk'
    # - 'g++'
    # - 'gcc'
    # - 'gdb'
    # - 'gfortran'
    # - 'groff-base'
    # - 'libblas-dev'
    # - 'libbz2-dev'
    # - 'libcairo2-dev'
    # - 'libcurl4-openssl-dev'
    # - 'libjpeg-dev'
    # - 'liblapack-dev'
    # - 'liblzma-dev'
    # - 'libncurses5-dev'
    # - 'libpango1.0-dev'
    # - 'libpcre3-dev'
    # - 'libpng-dev'
    # - 'libreadline-dev'
    # - 'libtiff5-dev'
    # - 'libx11-dev'
    # - 'libxt-dev'
    # - 'mpack'
    # - 'subversion'
    # - 'tcl8.6-dev'
    # - 'texinfo'
    # - 'texlive-base'
    # - 'texlive-extra-utils'
    # - 'texlive-fonts-extra'
    # - 'texlive-fonts-recommended'
    # - 'texlive-latex-base'
    # - 'texlive-latex-extra'
    # - 'texlive-latex-recommended'
    # - 'tk8.6-dev'
    # - 'x11proto-core-dev'
    # - 'xauth'
    # - 'xdg-utils'
    # - 'xfonts-base'
    # - 'xvfb'
    # - 'zlib1g-dev'
    #
    # @seealso
    # - Refer to the 'Installation + Administration' manual.
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
    # - https://hub.docker.com/r/rocker/r-devel/dockerfile
    # - https://developer.r-project.org/
    # - https://svn.r-project.org/R/
    # - https://cran.r-project.org/doc/manuals/r-devel/
    #       R-admin.html#Getting-patched-and-development-versions
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://svn.r-project.org/R/trunk/Makefile.in
    # - https://github.com/archlinux/svntogit-packages/blob/
    #     b3c63075d83c8dea993b8d776b8f9970c58791fe/r/trunk/PKGBUILD
    # """
    local app conf_args deps dict
    koopa_assert_has_no_args "$#"
    build_deps=('pkg-config')
    deps=(
        # > 'bzip2'
        # > 'perl'
        # > 'unzip'
        # > 'which'
        # > 'zip'
        'zlib'
        'gettext'
        'curl'
        'icu4c'
        'lapack'
        'libffi'
        'libjpeg-turbo'
        'libpng'
        'libtiff'
        'libxml2'
        'openblas'
        'pcre'
        'pcre2'
        'readline'
        'tcl-tk'
        'texinfo'
        'glib' # cairo
        'freetype' # cairo
        'fontconfig' # cairo
        'lzo' # cairo
        'pixman' # cairo
        'xorg-xorgproto'
        'xorg-xcb-proto'
        'xorg-libpthread-stubs'
        'xorg-libice'
        'xorg-libsm'
        'xorg-libxau'
        'xorg-libxdmcp'
        'xorg-libxcb'
        'xorg-libx11'
        'xorg-libxext'
        'xorg-libxrender'
        'xorg-libxt'
        'cairo'
        'xz'
    )
    if koopa_is_linux
    then
        deps+=(
            'openjdk'
        )
    elif koopa_is_macos
    then
        # We're using Adoptium Temurin LTS for OpenJDK on macOS.
        deps+=('gcc')
        koopa_add_to_path_start '/Library/TeX/texbin'
        # > koopa_add_to_pkg_config_path '/opt/X11/lib/pkgconfig'
    fi
    koopa_activate_build_opt_prefix "${build_deps[@]}"
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        [make]="$(koopa_locate_make)"
        [pkg_config]="$(koopa_locate_pkg_config)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[lapack]="$(koopa_realpath "${dict[opt_prefix]}/lapack")"
    dict[tcl_tk]="$(koopa_realpath "${dict[opt_prefix]}/tcl-tk")"
    conf_args=(
        # > '--enable-BLAS-shlib' # Linux only?
        "--prefix=${dict[prefix]}"
        '--enable-R-profiling'
        '--enable-R-shlib'
        '--enable-byte-compiled-packages'
        '--enable-fast-install'
        '--enable-java'
        '--enable-memory-profiling'
        '--enable-shared'
        '--enable-static'
        "--with-ICU=$( \
            "${app[pkg_config]}" --libs \
                'icu-i18n' \
                'icu-io' \
                'icu-uc' \
        )"
        "--with-blas=$( \
            "${app[pkg_config]}" --libs 'openblas' \
        )"
        # On macOS only, consider including:
        # - 'cairo-quartz'
        # - 'cairo-quartz-font'
        "--with-cairo=$( \
            "${app[pkg_config]}" --libs \
                'cairo' \
                'cairo-fc' \
                'cairo-ft' \
                'cairo-pdf' \
                'cairo-png' \
                'cairo-ps' \
                'cairo-script' \
                'cairo-svg' \
                'cairo-xcb' \
                'cairo-xcb-shm' \
                'cairo-xlib' \
                'cairo-xlib-xrender' \
        )"
        '--with-static-cairo=no'
        "--with-jpeglib=$( \
            "${app[pkg_config]}" --libs 'libjpeg' \
        )"
        "--with-lapack=$( \
            "${app[pkg_config]}" --libs 'lapack' \
        )"
        "--with-libpng=$( \
            "${app[pkg_config]}" --libs 'libpng' \
        )"
        "--with-libtiff=$( \
            "${app[pkg_config]}" --libs 'libtiff-4' \
        )"
        "--with-pcre2=$( \
            "${app[pkg_config]}" --libs \
                'libpcre2-8' \
                'libpcre2-16' \
                'libpcre2-32' \
                'libpcre2-posix' \
        )"
        "--with-readline=$( \
            "${app[pkg_config]}" --libs 'readline' \
        )"
        "--with-tcl-config=${dict[tcl_tk]}/lib/tclConfig.sh"
        "--with-tk-config=${dict[tcl_tk]}/lib/tkConfig.sh"
        '--with-x'
    )
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        conf_args+=('--without-recommended-packages')
    else
        conf_args+=('--with-recommended-packages')
    fi
    if koopa_is_macos
    then
        app[cc]='/usr/bin/clang'
        app[cxx]='/usr/bin/clang++'
        app[fc]="$(koopa_realpath "${dict[opt_prefix]}/gcc/bin/gfortran")"
        conf_args+=(
            "CC=${app[cc]}"
            "CXX=${app[cxx]}"
            "FC=${app[fc]}"
            "F77=${app[fc]}"
            "OBJC=${app[cc]}"
            "OBJCXX=${app[cxx]}"
            # > '--x-includes=/opt/X11/include'
            # > '--x-libraries=/opt/X11/lib'
            '--without-aqua'
        )
        export CFLAGS="-Wno-error=implicit-function-declaration ${CFLAGS:-}"
    fi
    koopa_dl 'configure args' "${conf_args[*]}"
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        app[svn]="$(koopa_locate_svn)"
        dict[rtop]="$(koopa_init_dir 'svn/r')"
        dict[svn_url]='https://svn.r-project.org/R/trunk'
        dict[trust_cert]='unknown-ca,cn-mismatch,expired,not-yet-valid,other'
        # Can debug subversion linkage with:
        # > "${app[svn]}" --version --verbose
        "${app[svn]}" \
            --non-interactive \
            --trust-server-cert-failures="${dict[trust_cert]}" \
            checkout \
                --revision="${dict[version]}" \
                "${dict[svn_url]}" \
                "${dict[rtop]}"
        koopa_cd "${dict[rtop]}"
        # Edge case for 'Makefile:107' issue.
        if koopa_is_macos
        then
            koopa_print "Revision: ${dict[version]}" > 'SVNINFO'
        fi
    else
        dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
        dict[file]="R-${dict[version]}.tar.gz"
        dict[url]="https://cloud.r-project.org/src/base/\
R-${dict[maj_ver]}/${dict[file]}"
        koopa_download "${dict[url]}" "${dict[file]}"
        koopa_extract "${dict[file]}"
        koopa_cd "R-${dict[version]}"
    fi
    export TZ='America/New_York'
    unset -v R_HOME
    # Need to burn in rpath, otherwise grDevices will fail to build.
    koopa_add_rpath_to_ldflags "${dict[lapack]}/lib"
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    # > "${app[make]}" 'pdf'
    "${app[make]}" 'info'
    "${app[make]}" install
    app[r]="${dict[prefix]}/bin/R"
    app[rscript]="${app[r]}script"
    koopa_assert_is_installed "${app[r]}" "${app[rscript]}"
    koopa_configure_r "${app[r]}"
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        koopa_link_in_bin "${app[r]}" 'R-devel'
    fi
    "${app[rscript]}" -e 'capabilities()'
    return 0
}
