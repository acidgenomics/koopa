#!/usr/bin/env bash

# FIXME Now hitting this OpenMP linker error on Ubuntu during install:
# R.bin Rmain.o  -lR
# /usr/bin/ld: ../../lib/libR.so: undefined reference to `GOMP_parallel'
# /usr/bin/ld: ../../lib/libR.so: undefined reference to `omp_get_thread_num'
# /usr/bin/ld: ../../lib/libR.so: undefined reference to `omp_get_num_threads'
# collect2: error: ld returned 1 exit status
# This is working correctly on macOS though...

# FIXME This is currently working on macOS because we installed OpenMP here:
# /usr/local/lib/libomp.dylib

main() {
    # """
    # Install R.
    # @note Updated 2022-07-19.
    #
    # @section gfortran configuration on macOS:
    #
    # - https://mac.r-project.org
    # - https://github.com/fxcoudert/gfortran-for-macOS/releases
    # - https://github.com/Rdatatable/data.table/wiki/Installation/
    # - https://developer.r-project.org/Blog/public/2020/11/02/
    #     will-r-work-on-apple-silicon/index.html
    # - https://bugs.r-project.org/bugzilla/show_bug.cgi?id=18024
    #
    # @seealso
    # - Refer to the 'Installation + Administration' manual.
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://cran.r-project.org/doc/manuals/r-release/
    #     R-admin.html#macOS-packages
    # - https://cran.r-project.org/doc/manuals/r-devel/
    #     R-exts.html#Using-Makevars
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
    # - https://developer.r-project.org/
    # - https://svn.r-project.org/R/
    # - https://www.gnu.org/software/make/manual/make.html#Using-Implicit
    # - https://www.gnu.org/software/make/manual/html_node/
    #     Implicit-Variables.html
    # - https://bookdown.org/lionel/contributing/building-r.html
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://hub.docker.com/r/rocker/r-devel/dockerfile
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - https://cran.r-project.org/doc/manuals/r-devel/
    #       R-admin.html#Getting-patched-and-development-versions
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://svn.r-project.org/R/trunk/Makefile.in
    # - https://github.com/archlinux/svntogit-packages/blob/
    #     b3c63075d83c8dea993b8d776b8f9970c58791fe/r/trunk/PKGBUILD
    # """
    local app conf_args deps dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
        [pkg_config]="$(koopa_locate_pkg_config)"
    )
    [[ -x "${app[make]}" ]] || return 1
    [[ -x "${app[pkg_config]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa_is_macos
    then
        dict[x11_prefix]='/opt/X11'
    fi
    build_deps=('pkg-config')
    deps=()
    if koopa_is_linux
    then
        deps+=('zlib')
    fi
    deps+=(
        'gcc'
        'bzip2'
        'icu4c'
        'ncurses'
        'readline'
        'libxml2'
        'gettext'
        'xz'
        'openssl3'
        'curl'
        'lapack'
        'libffi'
        'libjpeg-turbo'
        'libpng'
        'libtiff'
        'openblas'
        'openjdk'
        'pcre'
        'pcre2'
        'tcl-tk'
        'texinfo'
        'glib' # cairo
        'freetype' # cairo
        'fontconfig' # cairo
        'lzo' # cairo
        'pixman' # cairo
        # Added these on 2022-07-19:
        'zstd'
        'fribidi'
        'graphviz'
        'harfbuzz'
        'imagemagick'
        'libgit2'
        'sqlite'
        'geos'
        'proj'
        'gdal'
    )
    if koopa_is_macos
    then
        koopa_add_to_pkg_config_path "${dict[x11_prefix]}/lib/pkgconfig"
        koopa_add_to_path_start '/Library/TeX/texbin'
    else
        deps+=(
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
        )
    fi
    # Cairo depends on X11.
    deps+=('cairo')
    koopa_activate_build_opt_prefix "${build_deps[@]}"
    koopa_activate_opt_prefix "${deps[@]}"
    dict[lapack]="$(koopa_realpath "${dict[opt_prefix]}/lapack")"
    dict[tcl_tk]="$(koopa_realpath "${dict[opt_prefix]}/tcl-tk")"
    conf_args=(
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
    )
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        conf_args+=('--without-recommended-packages')
    else
        conf_args+=('--with-recommended-packages')
    fi
    dict[gcc_prefix]="$(koopa_realpath "${dict[opt_prefix]}/gcc")"
    app[cc]="${dict[gcc_prefix]}/bin/gcc"
    app[cxx]="${dict[gcc_prefix]}/bin/g++"
    app[fc]="${dict[gcc_prefix]}/bin/gfortran"
    koopa_assert_is_installed \
        "${app[cc]}" \
        "${app[cxx]}" \
        "${app[fc]}"
    conf_args+=(
        "CC=${app[cc]}"
        "CXX=${app[cxx]}"
        "F77=${app[fc]}"
        "FC=${app[fc]}"
        "OBJC=${app[cc]}"
        "OBJCXX=${app[cxx]}"
    )
    if koopa_is_macos
    then
        conf_args+=(
            "--x-includes=${dict[x11_prefix]}/include"
            "--x-libraries=${dict[x11_prefix]}/lib"
            '--without-aqua'
        )
        export CFLAGS="-Wno-error=implicit-function-declaration ${CFLAGS:-}"
    else
        conf_args+=('--with-x')
    fi
    koopa_dl 'configure args' "${conf_args[*]}"
    if [[ "${dict[name]}" == 'r-devel' ]]
    then
        app[svn]="$(koopa_locate_svn)"
        [[ -x "${app[svn]}" ]] || return 1
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
    ./configure --help
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
