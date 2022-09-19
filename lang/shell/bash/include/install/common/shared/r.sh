#!/usr/bin/env bash

# NOTE Consider adding an assert check for libomp in /usr/local for macOS.
# NOTE Need to reduce the number of rpath dependencies here, and offload to
#      ldpaths instead.

main() {
    # """
    # Install R.
    # @note Updated 2022-09-19.
    #
    # @seealso
    # - Refer to the 'Installation + Administration' manual.
    # - https://cran.r-project.org/doc/manuals/r-release/R-admin.html
    # - https://cran.r-project.org/doc/manuals/r-release/
    #     R-admin.html#macOS-packages
    # - https://cran.r-project.org/doc/manuals/r-devel/
    #     R-exts.html#Using-Makevars
    # - https://stat.ethz.ch/R-manual/R-devel/library/base/
    #     html/capabilities.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/r.rb
    # - https://github.com/macports/macports-ports/blob/master/math/R/Portfile
    # - https://developer.r-project.org/
    # - https://svn.r-project.org/R/
    # - https://www.gnu.org/software/make/manual/make.html#Using-Implicit
    # - https://www.gnu.org/software/make/manual/html_node/
    #     Implicit-Variables.html
    # - https://bookdown.org/lionel/contributing/building-r.html
    # - https://hub.docker.com/r/rocker/r-devel/dockerfile
    # - https://hub.docker.com/r/rocker/r-ver/dockerfile
    # - https://support.rstudio.com/hc/en-us/articles/
    #       218004217-Building-R-from-source
    # - https://cran.r-project.org/doc/manuals/r-devel/
    #       R-admin.html#Getting-patched-and-development-versions
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://svn.r-project.org/R/trunk/Makefile.in
    # - https://github.com/archlinux/svntogit-packages/blob/
    #     b3c63075d83c8dea993b8d776b8f9970c58791fe/r/trunk/PKGBUILD
    # """
    local app conf_args conf_dict deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    deps=(
        # zlib deps: none.
        'zlib'
        # zstd deps: none.
        'zstd'
        # m4 deps: none.
        # > 'm4'
        # gmp deps: m4.
        # > 'gmp'
        # mpfr deps: gmp.
        # > 'mpfr'
        # mpc deps: gmp, mpfr.
        # > 'mpc'
        # gcc deps: gmp, mpfr, mpc.
        'gcc'
    )
    # bzip2 deps: none.
    # R currently has configuration issues with libbz2.dylib on macOS.
    koopa_is_linux && deps+=('bzip2')
    deps+=(
        # deps: none.
        'icu4c'
        # deps: none.
        'ncurses'
        # deps: ncurses.
        'readline'
        # deps: icu4c, readline.
        'libxml2'
        # deps: none.
        'libiconv'
        # deps: bison, libiconv, libunistring, ncurses, libxml2.
        'gettext'
        # deps: none.
        'xz'
        # deps: zlib.
        'openssl3'
        # deps: openssl3.
        'curl'
        # deps: gcc.
        'lapack'
        # deps: none.
        'libffi'
        # deps: none.
        'libjpeg-turbo'
        # deps: zlib.
        'libpng'
        # deps: libjpeg-turbo, zstd.
        'libtiff'
        # deps: gcc.
        'openblas'
        # deps: none.
        'openjdk'
        # deps: zlib, bzip2.
        'pcre'
        # deps: zlib, bzip2.
        'pcre2'
        # deps: none.
        'perl'
        # deps: gettext, ncurses, perl.
        'texinfo'
        # deps: zlib, gettext, libffi, pcre.
        'glib'
        # deps: none.
        'freetype'
        # deps: none.
        'gperf'
        # deps: gperf, freetype, libxml2.
        'fontconfig'
        # deps: none.
        'lzo'
        # deps: none.
        'pixman'
        # deps: none.
        'fribidi'
        # deps: freetype, icu4c.
        'harfbuzz'
        # deps: m4.
        'libtool'
        # X11.
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
        # deps: gettext, freetype, libxml2, fontconfig, libffi, pcre, glib,
        # libpng, lzo, pixman, X11.
        'cairo'
        # deps: X11.
        'tcl-tk'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['ar']='/usr/bin/ar'
        ['awk']="$(koopa_locate_awk --realpath)"
        ['bash']="$(koopa_locate_bash --realpath)"
        ['echo']="$(koopa_locate_echo --realpath)"
        ['gfortran']="$(koopa_locate_gfortran --realpath)"
        ['jar']="$(koopa_locate_jar --realpath)"
        ['java']="$(koopa_locate_java --realpath)"
        ['javac']="$(koopa_locate_javac --realpath)"
        ['make']="$(koopa_locate_make)"
        ['perl']="$(koopa_locate_perl --realpath)"
        ['pkg_config']="$(koopa_locate_pkg_config)"
        ['sed']="$(koopa_locate_sed --realpath)"
        ['yacc']="$(koopa_locate_yacc --realpath)"
    )
    # The system clang compiler stack is preferred on macOS. If you attempt to
    # build with GCC, you'll run into a lot of compilation issues with
    # Posit/RStudio packages, which are only optimized for clang currently.
    if koopa_is_macos
    then
        if [[ ! -f '/usr/local/include/omp.h' ]]
        then
            koopa_stop \
                "'libomp' is not installed." \
                "Run 'koopa install system r-openmp' to resolve."
        fi
        app['cc']='/usr/bin/clang'
        app['cxx']='/usr/bin/clang++'
    else
        app['cc']="$(koopa_locate_gcc --realpath)"
        app['cxx']="$(koopa_locate_gcxx --realpath)"
    fi
    [[ -x "${app['ar']}" ]] || return 1
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['bash']}" ]] || return 1
    [[ -x "${app['cc']}" ]] || return 1
    [[ -x "${app['cxx']}" ]] || return 1
    [[ -x "${app['echo']}" ]] || return 1
    [[ -x "${app['gfortran']}" ]] || return 1
    [[ -x "${app['jar']}" ]] || return 1
    [[ -x "${app['java']}" ]] || return 1
    [[ -x "${app['javac']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['perl']}" ]] || return 1
    [[ -x "${app['pkg_config']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    [[ -x "${app['yacc']}" ]] || return 1
    declare -A conf_dict
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        # > ['bzip2']="$(koopa_app_prefix 'bzip2')"
        ['jobs']="$(koopa_cpu_count)"
        ['lapack']="$(koopa_app_prefix 'lapack')"
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['openjdk']="$(koopa_app_prefix 'openjdk')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['tcl_tk']="$(koopa_app_prefix 'tcl-tk')"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['lapack']}" \
        "${dict['openjdk']}" \
        "${dict['tcl_tk']}"
    if koopa_is_macos
    then
        dict['texbin']='/Library/TeX/texbin'
        koopa_assert_is_dir "${dict['texbin']}"
        koopa_add_to_path_start "${dict['texbin']}"
    fi
    conf_dict['with_blas']="$( \
        "${app['pkg_config']}" --libs 'openblas' \
    )"
    # On macOS, consider including: 'cairo-quartz', 'cairo-quartz-font'.
    conf_dict['with_cairo']="$( \
        "${app['pkg_config']}" --libs \
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
    conf_dict['with_icu']="$( \
        "${app['pkg_config']}" --libs \
            'icu-i18n' \
            'icu-io' \
            'icu-uc' \
    )"
    conf_dict['with_jpeglib']="$( \
        "${app['pkg_config']}" --libs 'libjpeg' \
    )"
    conf_dict['with_lapack']="$( \
        "${app['pkg_config']}" --libs 'lapack' \
    )"
    conf_dict['with_libpng']="$( \
        "${app['pkg_config']}" --libs 'libpng' \
    )"
    conf_dict['with_libtiff']="$( \
        "${app['pkg_config']}" --libs 'libtiff-4' \
    )"
    conf_dict['with_pcre2']="$( \
        "${app['pkg_config']}" --libs \
            'libpcre2-8' \
            'libpcre2-16' \
            'libpcre2-32' \
            'libpcre2-posix' \
    )"
    conf_dict['with_readline']="$( \
        "${app['pkg_config']}" --libs 'readline' \
    )"
    conf_dict['with_tcl_config']="${dict['tcl_tk']}/lib/tclConfig.sh"
    conf_dict['with_tk_config']="${dict['tcl_tk']}/lib/tkConfig.sh"
    koopa_assert_is_file \
        "${conf_dict['with_tcl_config']}" \
        "${conf_dict['with_tk_config']}"
    conf_dict['ar']="${app['ar']}"
    conf_dict['awk']="${app['awk']}"
    conf_dict['cc']="${app['cc']}"
    conf_dict['cxx']="${app['cxx']}"
    conf_dict['echo']="${app['echo']}"
    conf_dict['f77']="${app['gfortran']}"
    conf_dict['fc']="${app['gfortran']}"
    conf_dict['flibs']="$(koopa_gfortran_libs)"
    conf_dict['jar']="${app['jar']}"
    conf_dict['java']="${app['java']}"
    conf_dict['java_home']="${dict['openjdk']}"
    conf_dict['javac']="${app['javac']}"
    conf_dict['javah']=''
    conf_dict['libnn']='lib'
    conf_dict['objc']="${app['cc']}"
    conf_dict['objcxx']="${app['cxx']}"
    conf_dict['perl']="${app['perl']}"
    conf_dict['r_shell']="${app['bash']}"
    conf_dict['sed']="${app['sed']}"
    # Alternatively, can use 'bison -y'.
    conf_dict['yacc']="${app['yacc']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--enable-R-profiling'
        '--enable-R-shlib'
        '--enable-byte-compiled-packages'
        '--enable-fast-install'
        '--enable-java'
        '--enable-memory-profiling'
        '--enable-shared'
        '--enable-static'
        "--with-ICU=${conf_dict['with_icu']}"
        "--with-blas=${conf_dict['with_blas']}"
        "--with-cairo=${conf_dict['with_cairo']}"
        "--with-jpeglib=${conf_dict['with_jpeglib']}"
        "--with-lapack=${conf_dict['with_lapack']}"
        "--with-libpng=${conf_dict['with_libpng']}"
        "--with-libtiff=${conf_dict['with_libtiff']}"
        "--with-pcre2=${conf_dict['with_pcre2']}"
        "--with-readline=${conf_dict['with_readline']}"
        "--with-tcl-config=${conf_dict['with_tcl_config']}"
        "--with-tk-config=${conf_dict['with_tk_config']}"
        '--with-static-cairo=no'
        '--with-x'
        '--without-recommended-packages'
        "AR=${conf_dict['ar']}"
        "AWK=${conf_dict['awk']}"
        "CC=${conf_dict['cc']}"
        "CXX=${conf_dict['cxx']}"
        "ECHO=${conf_dict['echo']}"
        "F77=${conf_dict['f77']}"
        "FC=${conf_dict['fc']}"
        "FLIBS=${conf_dict['flibs']}"
        "JAR=${conf_dict['jar']}"
        "JAVA=${conf_dict['java']}"
        "JAVAC=${conf_dict['javac']}"
        "JAVAH=${conf_dict['javah']}"
        "JAVA_HOME=${conf_dict['java_home']}"
        "LIBnn=${conf_dict['libnn']}"
        "OBJC=${conf_dict['objc']}"
        "OBJCXX=${conf_dict['objcxx']}"
        "PERL=${conf_dict['perl']}"
        "R_SHELL=${conf_dict['r_shell']}"
        "SED=${conf_dict['sed']}"
        "YACC=${conf_dict['yacc']}"
    )
    # This is required to use R with RStudio on macOS.
    koopa_is_macos && conf_args+=('--with-aqua')
    if [[ "${dict['name']}" == 'r-devel' ]]
    then
        conf_args+=('--program-suffix=dev')
        app['svn']="$(koopa_locate_svn)"
        [[ -x "${app['svn']}" ]] || return 1
        dict['rtop']="$(koopa_init_dir 'svn/r')"
        dict['svn_url']='https://svn.r-project.org/R/trunk'
        dict['trust_cert']='unknown-ca,cn-mismatch,expired,not-yet-valid,other'
        # Can debug subversion linkage with:
        # > "${app['svn']}" --version --verbose
        "${app['svn']}" \
            --non-interactive \
            --trust-server-cert-failures="${dict['trust_cert']}" \
            checkout \
                --revision="${dict['version']}" \
                "${dict['svn_url']}" \
                "${dict['rtop']}"
        koopa_cd "${dict['rtop']}"
        koopa_print "Revision: ${dict['version']}" > 'SVNINFO'
    else
        dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
        dict['file']="R-${dict['version']}.tar.gz"
        dict['url']="https://cloud.r-project.org/src/base/\
R-${dict['maj_ver']}/${dict['file']}"
        koopa_download "${dict['url']}" "${dict['file']}"
        koopa_extract "${dict['file']}"
        koopa_cd "R-${dict['version']}"
    fi
    # Need to burn LAPACK in rpath, otherwise grDevices can fail to build.
    koopa_add_rpath_to_ldflags "${dict['lapack']}/lib"
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    # > "${app['make']}" check
    # > "${app['make']}" pdf
    "${app['make']}" 'info'
    "${app['make']}" install
    app['r']="${dict['prefix']}/bin/R"
    app['rscript']="${dict['prefix']}/bin/Rscript"
    koopa_assert_is_installed "${app['r']}" "${app['rscript']}"
    koopa_configure_r "${app['r']}"
    # NOTE libxml is now expected to return FALSE as of R 4.2.
    "${app['rscript']}" -e 'capabilities()'
    koopa_check_shared_object \
        --name='libR' \
        --prefix="${dict['prefix']}/lib/R/lib"
    if [[ "${dict['name']}" != 'r-devel' ]]
    then
        koopa_install_r_koopa "${app['r']}"
    fi
    return 0
}
