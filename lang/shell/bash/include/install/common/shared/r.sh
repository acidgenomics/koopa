#!/usr/bin/env bash

# NOTE Don't include graphviz here, as it can cause conflicts with Rgraphviz
# package in R, which bundles a very old version (2.28.0) currently.

main() {
    # """
    # Install R.
    # @note Updated 2022-08-28.
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
    # @section R-spatial evolution:
    #
    # R-spatial packages are being reworked. rgdal, rgeos, and maptools will be
    # retired in 2023 in favor of more modern packages, such as sf. When this
    # occurs, it may be possible to remove the geospatial libraries (geos, proj,
    # gdal) as dependencies here.
    #
    # https://r-spatial.org/r/2022/04/12/evolution.html
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
    local app conf_args conf_dict deps dict flibs i libs
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
        # bzip2 deps: none.
        'bzip2'
        # icu4c deps: none.
        'icu4c'
        # ncurses deps: none.
        'ncurses'
        # readline deps: ncurses.
        'readline'
        # libxml2 deps: icu4c, readline.
        'libxml2'
        # gettext deps: ncurses, libxml2.
        'gettext'
        # xz deps: none.
        'xz'
        # openssl3 deps: zlib.
        'openssl3'
        # curl deps: openssl3.
        'curl'
        # lapack deps: gcc.
        'lapack'
        # libffi deps: none.
        'libffi'
        # libjpeg-turbo deps: none.
        'libjpeg-turbo'
        # libpng deps: zlib.
        'libpng'
        # libtiff deps: libjpeg-turbo, zstd.
        'libtiff'
        # openblas deps: gcc.
        'openblas'
        # openjdk deps: none.
        'openjdk'
        # pcre deps: zlib, bzip2.
        'pcre'
        # pcre2 deps: zlib, bzip2.
        'pcre2'
        # perl deps: none.
        'perl'
        # texinfo deps: gettext, ncurses, perl.
        'texinfo'
        # glib deps: zlib, gettext, libffi, pcre.
        'glib'
        # freetype deps: none.
        'freetype'
        # gperf deps: none.
        'gperf'
        # fontconfig deps: gperf, freetype, libxml2.
        'fontconfig'
        # lzo deps: none.
        'lzo'
        # pixman deps: none.
        'pixman'
        # fribidi deps: none.
        'fribidi'
        # harfbuzz deps: freetype, icu4c.
        'harfbuzz'
        # libtool deps: m4.
        'libtool'
        # imagemagick deps: libtool.
        'imagemagick'
        # libssh2 deps: openssl3.
        'libssh2'
        # libgit2 deps: openssl3, libssh2.
        'libgit2'
        # sqlite deps: readline.
        'sqlite'
        # python deps: zlib, libffi, openssl3.
        'python'
        # hdf5 deps: gcc.
        'hdf5'
        # geos deps: none.
        'geos'
        # proj deps: curl, libtiff, python, sqlite.
        'proj'
        # gdal deps: curl, geos, hdf5, libxml2, openssl3, pcre2, sqlite,
        # libtiff, proj, xz, zstd.
        'gdal'
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
        # cairo deps: gettext, freetype, libxml2, fontconfig, libffi,
        # pcre, glib, libpng, lzo, pixman, X11.
        'cairo'
        # tcl-tk deps: X11.
        'tcl-tk'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        ['dirname']="$(koopa_locate_dirname)"
        ['make']="$(koopa_locate_make)"
        ['pkg_config']="$(koopa_locate_pkg_config)"
        ['sort']="$(koopa_locate_sort)"
        ['xargs']="$(koopa_locate_xargs)"
    )
    [[ -x "${app['dirname']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['pkg_config']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    conf_args=()
    declare -A conf_dict
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['bzip2']="$(koopa_app_prefix 'bzip2')"
        ['gcc']="$(koopa_app_prefix 'gcc')"
        ['jobs']="$(koopa_cpu_count)"
        ['lapack']="$(koopa_app_prefix 'lapack')"
        ['name']='r'
        ['openjdk']="$(koopa_app_prefix 'openjdk')"
        ['prefix']="${INSTALL_PREFIX:?}"
        ['tcl_tk']="$(koopa_app_prefix 'tcl-tk')"
        ['version']="${INSTALL_VERSION:?}"
    )
    if koopa_is_macos
    then
        dict['texbin']='/Library/TeX/texbin'
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
    if koopa_is_macos
    then
        # Clang tends to compile a number of tricky RStudio packages better.
        conf_dict['cc']='/usr/bin/clang'
        conf_dict['cxx']='/usr/bin/clang++'
    else
        # Alternatively, can use system GCC here.
        # > conf_dict['cc']='/usr/bin/gcc'
        # > conf_dict['cxx']='/usr/bin/g++'
        conf_dict['cc']="${dict['gcc']}/bin/gcc"
        conf_dict['cxx']="${dict['gcc']}/bin/g++"
    fi
    conf_dict['ar']='/usr/bin/ar'
    conf_dict['awk']="$(koopa_locate_awk --realpath)"
    conf_dict['echo']="$(koopa_locate_echo --realpath)"
    conf_dict['fc']="$(koopa_locate_gfortran --realpath)"
    conf_dict['jar']="$(koopa_locate_jar --realpath)"
    conf_dict['java']="$(koopa_locate_java --realpath)"
    conf_dict['javac']="$(koopa_locate_javac --realpath)"
    conf_dict['perl']="$(koopa_locate_perl --realpath)"
    conf_dict['r_shell']="$(koopa_locate_bash --realpath)"
    conf_dict['sed']="$(koopa_locate_sed --realpath)"
    # Alternatively, can use 'bison -y' for YACC.
    conf_dict['yacc']="$(koopa_locate_yacc --realpath)"
    koopa_assert_is_installed \
        "${conf_dict['ar']}" \
        "${conf_dict['awk']}" \
        "${conf_dict['cc']}" \
        "${conf_dict['cxx']}" \
        "${conf_dict['echo']}" \
        "${conf_dict['fc']}" \
        "${conf_dict['jar']}" \
        "${conf_dict['java']}" \
        "${conf_dict['javac']}" \
        "${conf_dict['perl']}" \
        "${conf_dict['r_shell']}" \
        "${conf_dict['sed']}" \
        "${conf_dict['yacc']}"
    conf_dict['f77']="${conf_dict['fc']}"
    conf_dict['java_home']="${dict['openjdk']}"
    # > conf_dict['javah']="${conf_dict['javac']} -h"
    conf_dict['javah']=''
    conf_dict['objc']="${conf_dict['cc']}"
    conf_dict['objcxx']="${conf_dict['cxx']}"
    if koopa_is_linux
    then
        conf_dict['cc']="${conf_dict['cc']} -fopenmp"
    fi
    # Configure fortran FLIBS to link GCC correctly.
    readarray -t libs <<< "$( \
        koopa_find \
            --prefix="${dict['gcc']}" \
            --pattern='*.a' \
            --type 'f' \
        | "${app['xargs']}" -I '{}' "${app['dirname']}" '{}' \
        | "${app['sort']}" --unique \
    )"
    koopa_assert_is_array_non_empty "${libs[@]:-}"
    flibs=()
    for i in "${!libs[@]}"
    do
        flibs+=("-L${libs[$i]}")
    done
    flibs+=('-lgfortran')
    # quadmath is not yet supported for ARM.
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=96016
    case "${dict['arch']}" in
        'x86_64')
            flibs+=('-lquadmath')
            ;;
    esac
    # Consider also including '-lemutls_w' here, which is recommended by
    # macOS CRAN binary build config.
    flibs+=('-lm')
    conf_dict['flibs']="${flibs[*]}"
    # Consider also setting these, based on rocker Dockerfile.
    # > 'PAGER=<PAGER>'
    # > 'R_UNZIPCMD=<UNZIP>'
    # > 'R_ZIPCMD=<ZIP>'
    conf_args+=(
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
        'LIBnn=lib'
        "OBJC=${conf_dict['objc']}"
        "OBJCXX=${conf_dict['objcxx']}"
        "PERL=${conf_dict['perl']}"
        'R_BATCHSAVE=--no-save --no-restore'
        'R_PAPERSIZE=letter'
        "R_SHELL=${conf_dict['r_shell']}"
        "SED=${conf_dict['sed']}"
        "YACC=${conf_dict['yacc']}"
    )
    if koopa_is_linux
    then
        conf_args+=(
            'R_BROWSER=xdg-open'
            'R_PRINTCMD=lpr'
        )
    fi
    if koopa_is_macos
    then
        # This is required for plotting support in RStudio.
        conf_args+=('--with-aqua')
        export CFLAGS="-Wno-error=implicit-function-declaration ${CFLAGS:-}"
    else
        # Ensure that OpenMP is enabled. Only 'CFLAGS', 'CXXFLAGS', and 'FFLAGS'
        # (but not 'FCFLAGS') get defined in Makeconf' file.
        # https://stackoverflow.com/a/12307488/3911732
        conf_args+=(
            'SHLIB_OPENMP_CFLAGS=-fopenmp'
            'SHLIB_OPENMP_CXXFLAGS=-fopenmp'
            'SHLIB_OPENMP_FFLAGS=-fopenmp'
        )
    fi
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
    unset -v R_HOME
    # Setting the time zone used to be required for build to complete.
    # > export TZ='America/New_York'
    # Need to burn LAPACK in rpath, otherwise grDevices can fail to build.
    koopa_add_rpath_to_ldflags "${dict['lapack']}/lib"
    ./configure --help
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # > "${app['make']}" check
    # > "${app['make']}" 'pdf'
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
    return 0
}
