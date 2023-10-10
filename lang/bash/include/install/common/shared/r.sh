#!/usr/bin/env bash

# Fortran configuration hell:
# https://stat.ethz.ch/pipermail/r-sig-debian/2014-September/002322.html
# https://stat.ethz.ch/pipermail/r-help/2014-February/366245.html
# https://stackoverflow.com/questions/22555526/set-cxxflags-in-rcpp-makevars
# https://trac.macports.org/ticket/44084
# https://stackoverflow.com/questions/25033951/
# https://stackoverflow.com/questions/22555526/
# https://github.com/Homebrew/legacy-homebrew/issues/12776
# https://github.com/Homebrew/legacy-homebrew/issues/19949
# https://trac.macports.org/ticket/44084

main() {
    # """
    # Install R.
    # @note Updated 2023-10-09.
    #
    # @section Compiler settings:
    #
    # The system clang compiler stack is preferred on macOS. If you attempt to
    # build with GCC, you'll run into a lot of compilation issues with
    # Posit/RStudio packages, which are only optimized for clang currently.
    #
    # @section External dependencies:
    #
    # This install script is intentionally linking to system bzip2 on macOS.
    # R currently has configuration issues with our 'libbz2.dylib' on macOS.
    #
    # cURL 8 currently fails build checks.
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
    # - https://svn.r-project.org/R/trunk/configure
    # """
    local -A app bool conf_dict dict
    local -a build_deps conf_args deps r_pkgs
    local r_pkg
    bool['devel']=0
    bool['r_koopa']=1
    build_deps=('autoconf' 'automake' 'libtool' 'make' 'pkg-config')
    koopa_activate_app --build-only "${build_deps[@]}"
    ! koopa_is_macos && deps+=('bzip2')
    deps+=(
        'xz'
        'zlib' # libpng
        'zstd' # libtiff
        # > 'gcc'
        'gettext'
        'icu4c'
        'readline'
        'curl'
        # > 'lapack'
        'libjpeg-turbo'
        'libpng'
        'libtiff'
        'openblas'
        'pcre2'
        'texinfo'
        'libffi' # glib > cairo
        'glib' # cairo
        'freetype' # cairo
        'libxml2' # fontconfig
        'fontconfig' # cairo
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
        'tcl-tk'
        'openssl3'
    )
    koopa_activate_app "${deps[@]}"
    app['ar']="$(koopa_locate_ar --only-system)"
    app['awk']="$(koopa_locate_awk)"
    app['bash']="$(koopa_locate_bash)"
    app['bzip2']="$(koopa_locate_bzip2)"
    app['cc']="$(koopa_locate_cc --only-system)"
    app['cxx']="$(koopa_locate_cxx --only-system)"
    app['echo']="$(koopa_locate_echo)"
    if koopa_is_macos
    then
        app['gfortran']='/opt/gfortran/bin/gfortran'
    else
        app['gfortran']="$(koopa_locate_gfortran)"
    fi
    app['gzip']="$(koopa_locate_gzip)"
    app['jar']="$(koopa_locate_jar)"
    app['java']="$(koopa_locate_java)"
    app['javac']="$(koopa_locate_javac)"
    app['less']="$(koopa_locate_less)"
    app['ln']="$(koopa_locate_ln)"
    app['make']="$(koopa_locate_make)"
    app['perl']="$(koopa_locate_perl)"
    app['pkg_config']="$(koopa_locate_pkg_config)"
    app['sed']="$(koopa_locate_sed)"
    app['strip']="$(koopa_locate_strip)"
    app['tar']="$(koopa_locate_tar)"
    app['texi2dvi']="$(koopa_locate_texi2dvi)"
    app['unzip']="$(koopa_locate_unzip)"
    app['vim']="$(koopa_locate_vim)"
    app['yacc']="$(koopa_locate_yacc)"
    app['zip']="$(koopa_locate_zip)"
    koopa_assert_is_executable "${app[@]}"
    app['lpr']="$(koopa_locate_lpr --allow-missing)"
    app['open']="$(koopa_locate_open --allow-missing)"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['tcl_tk']="$(koopa_app_prefix 'tcl-tk')"
    dict['temurin']="$(koopa_app_prefix 'temurin')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    [[ "${dict['name']}" == 'r-devel' ]] && bool['devel']=1
    conf_dict['ar']="${app['ar']}"
    conf_dict['awk']="${app['awk']}"
    conf_dict['cc']="${app['cc']}"
    conf_dict['cxx']="${app['cxx']}"
    conf_dict['echo']="${app['echo']}"
    conf_dict['editor']="${app['vim']}"
    conf_dict['f77']="${app['gfortran']}"
    conf_dict['fc']="${app['gfortran']}"
    # FIXME This doesn't match the default R system config, double check.
    conf_dict['fcflags']='-g -O2 $(LTO_FC)'
    conf_dict['fclibs']="$(koopa_r_gfortran_libs)"
    conf_dict['fflags']='-g -O2 $(LTO_FC)'
    conf_dict['flibs']="$(koopa_r_gfortran_libs)"
    conf_dict['jar']="${app['jar']}"
    conf_dict['java']="${app['java']}"
    conf_dict['java_home']="${dict['temurin']}"
    conf_dict['javac']="${app['javac']}"
    conf_dict['javah']=''
    conf_dict['libnn']='lib'
    conf_dict['ln_s']="${app['ln']} -s"
    conf_dict['make']="${app['make']}"
    conf_dict['objc']="${app['cc']}"
    conf_dict['objcxx']="${app['cxx']}"
    conf_dict['pager']="${app['less']}"
    conf_dict['perl']="${app['perl']}"
    conf_dict['r_batchsave']='--no-save --no-restore'
    conf_dict['r_browser']="${app['open']}"
    conf_dict['r_bzipcmd']="${app['bzip2']}"
    conf_dict['r_gzipcmd']="${app['gzip']}"
    conf_dict['r_libs_site']="\${R_HOME}/site-library"
    conf_dict['r_libs_user']="\${R_LIBS_SITE}"
    conf_dict['r_papersize']='letter'
    conf_dict['r_papersize_user']="\${R_PAPERSIZE}"
    conf_dict['r_pdfviewer']="${app['open']}"
    conf_dict['r_printcmd']="${app['lpr']}"
    conf_dict['r_shell']="${app['bash']}"
    conf_dict['r_strip_shared_lib']="${app['strip']} -x"
    conf_dict['r_strip_static_lib']="${app['strip']} -S"
    conf_dict['r_texi2dvicmd']="${app['texi2dvi']}"
    conf_dict['r_unzipcmd']="${app['unzip']}"
    conf_dict['r_zipcmd']="${app['zip']}"
    conf_dict['sed']="${app['sed']}"
    conf_dict['tar']="${app['tar']}"
    conf_dict['tz']="\${TZ:-America/New_York}"
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
    # > conf_dict['with_lapack']="$( \
    # >     "${app['pkg_config']}" --libs 'lapack' \
    # > )"
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
    # Alternatively, can use 'bison -y'.
    conf_dict['yacc']="${app['yacc']}"
    koopa_assert_is_file \
        "${conf_dict['with_tcl_config']}" \
        "${conf_dict['with_tk_config']}"
    conf_args+=(
        '--disable-static'
        '--enable-R-profiling'
        '--enable-R-shlib'
        '--enable-byte-compiled-packages'
        '--enable-fast-install'
        '--enable-java'
        '--enable-memory-profiling'
        '--enable-shared'
        "--prefix=${dict['prefix']}"
        "--with-ICU=${conf_dict['with_icu']}"
        "--with-blas=${conf_dict['with_blas']}"
        "--with-cairo=${conf_dict['with_cairo']}"
        "--with-jpeglib=${conf_dict['with_jpeglib']}"
        # > "--with-lapack=${conf_dict['with_lapack']}"
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
        "EDITOR=${conf_dict['editor']}"
        "F77=${conf_dict['f77']}"
        "FC=${conf_dict['fc']}"
        "FCFLAGS=${conf_dict['fcflags']}"
        "FCLIBS=${conf_dict['fclibs']}"
        "FFLAGS=${conf_dict['fflags']}"
        "FLIBS=${conf_dict['flibs']}"
        "JAR=${conf_dict['jar']}"
        "JAVA=${conf_dict['java']}"
        "JAVAC=${conf_dict['javac']}"
        "JAVAH=${conf_dict['javah']}"
        "JAVA_HOME=${conf_dict['java_home']}"
        "LIBnn=${conf_dict['libnn']}"
        "LN_S=${conf_dict['ln_s']}"
        "MAKE=${conf_dict['make']}"
        "OBJC=${conf_dict['objc']}"
        "OBJCXX=${conf_dict['objcxx']}"
        "PAGER=${conf_dict['pager']}"
        "PERL=${conf_dict['perl']}"
        "R_BATCHSAVE=${conf_dict['r_batchsave']}"
        "R_BROWSER=${conf_dict['r_browser']}"
        "R_BZIPCMD=${conf_dict['r_bzipcmd']}"
        "R_GZIPCMD=${conf_dict['r_gzipcmd']}"
        "R_LIBS_SITE=${conf_dict['r_libs_site']}"
        "R_LIBS_USER=${conf_dict['r_libs_user']}"
        "R_PAPERSIZE=${conf_dict['r_papersize']}"
        "R_PAPERSIZE_USER=${conf_dict['r_papersize_user']}"
        "R_PDFVIEWER=${conf_dict['r_pdfviewer']}"
        "R_PRINTCMD=${conf_dict['r_printcmd']}"
        "R_SHELL=${conf_dict['r_shell']}"
        "R_STRIP_SHARED_LIB=${conf_dict['r_strip_shared_lib']}"
        "R_STRIP_STATIC_LIB=${conf_dict['r_strip_static_lib']}"
        "R_TEXI2DVICMD=${conf_dict['r_texi2dvicmd']}"
        "R_UNZIPCMD=${conf_dict['r_unzipcmd']}"
        "R_ZIPCMD=${conf_dict['r_zipcmd']}"
        "SED=${conf_dict['sed']}"
        "TAR=${conf_dict['tar']}"
        "TZ=${conf_dict['tz']}"
        "YACC=${conf_dict['yacc']}"
    )
    if koopa_is_macos
    then
        dict['texbin']='/Library/TeX/texbin'
        if [[ -d "${dict['texbin']}" ]]
        then
            koopa_add_to_path_start "${dict['texbin']}"
        fi
        # Aqua framework is required to use R with RStudio on macOS. Currently
        # disabled due to build issues on macOS 13 with XCode CLT 14.
        conf_args+=('--without-aqua')
    fi
    if [[ "${bool['devel']}" -eq 1 ]]
    then
        bool['r_koopa']=0
        conf_args+=('--program-suffix=dev')
        app['svn']="$(koopa_locate_svn)"
        koopa_assert_is_executable "${app[@]}"
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
        dict['url']="https://cloud.r-project.org/src/base/\
R-${dict['maj_ver']}/R-${dict['version']}.tar.gz"
        koopa_download "${dict['url']}"
        koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
        koopa_cd 'src'
    fi
    # 'configure' doesn't detect curl 8 correctly.
    export r_cv_have_curl728='yes'
    # Fortran is required, and setting FLIBS alone isn't sufficient. Need to
    # append LDFLAGS currently as well.
    # > configure: error: Maybe check LDFLAGS for paths to Fortran libraries?
    # FIXME > koopa_append_ldflags "${conf_dict['flibs']}"
    if koopa_is_macos
    then
        # FIXME Rework using 'koopa_append_ldflags' and 'koopa_append_cppflags'.
        CPPFLAGS="${CPPFLAGS:-}"
        # May need to add '/opt/gfortran/lib/gcc/x86_64-apple-darwin20.0/12.2.0'.
        CPPFLAGS="${CPPFLAGS} -I/opt/gfortran/include"
        export CPPFLAGS
        LDFLAGS="${LDFLAGS:-}"
        LDFLAGS="${LDFLAGS} -L/opt/gfortran/lib -Wl,-rpath,/opt/gfortran/lib"
        export LDFLAGS
    fi
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    app['r']="${dict['prefix']}/bin/R"
    app['rscript']="${dict['prefix']}/bin/Rscript"
    koopa_assert_is_executable "${app['r']}" "${app['rscript']}"
    koopa_configure_r "${app['r']}"
    "${app['rscript']}" -e 'capabilities()'
    koopa_check_shared_object \
        --name='libR' \
        --prefix="${dict['prefix']}/lib/R/lib"
    if [[ "${bool['r_koopa']}" -eq 1 ]]
    then
        # Install our internal R koopa package.
        # NOTE Consider setting 'dependencies = NA' here to lighten the number
        # of packages that get installed into the system library here.
        "${app['rscript']}" -e " \
            options(
                error = quote(quit(status = 1L)),
                warn = 1L
            ); \
            if (!requireNamespace('BiocManager', quietly = TRUE)) { ; \
                install.packages('BiocManager'); \
            } ; \
            install.packages(
                pkgs = 'koopa',
                repos = c(
                    'https://r.acidgenomics.com',
                    BiocManager::repositories()
                ),
                dependencies = TRUE
            ); \
        "
        dict['site_lib']="${dict['prefix']}/lib/R/site-library"
        koopa_assert_is_dir "${dict['site_lib']}"
        r_pkgs=('koopa' 'pipette')
        for r_pkg in "${r_pkgs[@]}"
        do
            koopa_assert_is_dir "${dict['site_lib']}/${r_pkg}"
            "${app['rscript']}" -e "library(${r_pkg})"
        done
    fi
    return 0
}
