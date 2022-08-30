#!/usr/bin/env bash

koopa_r_configure_makevars() {
    # """
    # Configure 'Makevars.site' file with compiler settings.
    # @note Updated 2022-08-30.
    #
    # Consider setting 'TCLTK_CPPFLAGS' and 'TCLTK_LIBS' for extra hardened
    # configuration in the future.
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
    # - /opt/koopa/opt/r/lib/R/etc/Makeconf
    # - /Library/Frameworks/R.framework/Versions/Current/Resources/etc/Makeconf
    # """
    local app conf_dict dict
    local cppflags ldflags lines
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['ar']='/usr/bin/ar'
        ['awk']="$(koopa_locate_awk --realpath)"
        ['bash']="$(koopa_locate_bash --realpath)"
        ['echo']="$(koopa_locate_echo --realpath)"
        ['gfortran']="$(koopa_locate_gfortran --realpath)"
        ['pkg_config']="$(koopa_locate_pkg_config)"
        ['r']="${1:?}"
        ['ranlib']='/usr/bin/ranlib'
        ['sed']="$(koopa_locate_sed --realpath)"
        ['sort']="$(koopa_locate_sort)"
        ['strip']='/usr/bin/strip'
        ['yacc']="$(koopa_locate_yacc --realpath)"
    )
    # The system clang compiler stack is preferred on macOS. If you attempt to
    # build with GCC, you'll run into a lot of compilation issues with
    # Posit/RStudio packages, which are only optimized for clang currently.
    if koopa_is_macos
    then
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
    [[ -x "${app['pkg_config']}" ]] || return 1
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['ranlib']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['strip']}" ]] || return 1
    [[ -x "${app['yacc']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['freetype']="$(koopa_app_prefix 'freetype')"
        ['gettext']="$(koopa_app_prefix 'gettext')"
        ['jpeg']="$(koopa_app_prefix 'jpeg')"
        ['lapack']="$(koopa_app_prefix 'lapack')"
        ['libpng']="$(koopa_app_prefix 'libpng')"
        ['libtiff']="$(koopa_app_prefix 'libtiff')"
        ['openblas']="$(koopa_app_prefix 'openblas')"
        ['pcre2']="$(koopa_app_prefix 'pcre2')"
        ['r_prefix']="$(koopa_r_prefix "${app['r']}")"
        ['system']=0
        ['zlib']="$(koopa_app_prefix 'zlib')"
        ['zstd']="$(koopa_app_prefix 'zstd')"
    )
    koopa_assert_is_dir \
        "${dict['freetype']}" \
        "${dict['gettext']}" \
        "${dict['jpeg']}" \
        "${dict['lapack']}" \
        "${dict['libpng']}" \
        "${dict['libtiff']}" \
        "${dict['openblas']}" \
        "${dict['pcre2']}" \
        "${dict['r_prefix']}" \
        "${dict['zlib']}" \
        "${dict['zstd']}"
    dict['file']="${dict['r_prefix']}/etc/Makevars.site"
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    koopa_alert "Configuring '${dict['file']}'."
    koopa_add_to_pkg_config_path \
        "${dict['freetype']}/lib/pkgconfig" \
        "${dict['jpeg']}/lib/pkgconfig" \
        "${dict['lapack']}/lib/pkgconfig" \
        "${dict['libpng']}/lib/pkgconfig" \
        "${dict['libtiff']}/lib/pkgconfig" \
        "${dict['openblas']}/lib/pkgconfig" \
        "${dict['zlib']}/lib/pkgconfig" \
        "${dict['zstd']}/lib/pkgconfig"
    cppflags=()
    ldflags=()
    lines=()
    # gettext is needed to resolve clang '-lintl' warning. Can we avoid this
    # issue by setting 'LIBINTL' instead?
    cppflags+=(
        # > '-I/usr/local/include'
        "-I${dict['gettext']}/include"
    )
    ldflags+=(
        # > '-L/usr/local/lib'
        "-L${dict['gettext']}/lib"
    )
    # NOTE Custom LDFLAGS here appear to be incompatible with these packages:
    # fs, httpuv, igraph. May need to add support for bzip2, at least on Linux.
    case "${dict['system']}" in
        '1')
            cppflags+=(
                "$( \
                    "${app['pkg_config']}" --cflags \
                        'freetype2' \
                        'libjpeg' \
                        'libpng' \
                        'libtiff-4' \
                        'libzstd' \
                        'zlib' \
                )"
            )
            ldflags+=(
                "$( \
                    "${app['pkg_config']}" --libs-only-L \
                        'freetype2' \
                        'libjpeg' \
                        'libpng' \
                        'libtiff-4' \
                        'libzstd' \
                        'zlib' \
                )"
            )
            ;;
    esac
    ldflags+=('-lomp')
    declare -A conf_dict
    conf_dict['ar']="${app['ar']}"
    conf_dict['awk']="${app['awk']}"
    conf_dict['blas_libs']="$("${app['pkg_config']}" --libs 'openblas')"
    conf_dict['cc']="${app['cc']}"
    # NOTE Consider using '-O3' instead of '-O2' here.
    conf_dict['cflags']="-Wall -g -O2 \$(LTO)"
    conf_dict['cppflags']="${cppflags[*]}"
    conf_dict['cxx']="${app['cxx']} -std=gnu++14"
    conf_dict['echo']="${app['echo']}"
    conf_dict['f77']="${app['gfortran']}"
    conf_dict['fc']="${app['gfortran']}"
    conf_dict['fflags']="-Wall -g -O2 \$(LTO_FC)"
    conf_dict['flibs']="$(koopa_gfortran_libs)"
    conf_dict['lapack_libs']="$("${app['pkg_config']}" --libs 'lapack')"
    conf_dict['ldflags']="${ldflags[*]}"
    conf_dict['objc_libs']='-lobjc'
    conf_dict['objcflags']="-Wall -g -O2 -fobjc-exceptions \$(LTO)"
    conf_dict['ranlib']="${app['ranlib']}"
    conf_dict['safe_fflags']='-Wall -g -O2 -msse2 -mfpmath=sse'
    conf_dict['sed']="${app['sed']}"
    conf_dict['shell']="${app['bash']}"
    conf_dict['strip_shared_lib']="${app['strip']} -x"
    conf_dict['strip_static_lib']="${app['strip']} -S"
    # Alternatively, can use 'bison -y'.
    conf_dict['yacc']="${app['yacc']}"
    # These are values that inherit from other values in the dictionary.
    conf_dict['cxx11']="${conf_dict['cxx']}"
    conf_dict['cxx14']="${conf_dict['cxx']}"
    conf_dict['cxx17']="${conf_dict['cxx']}"
    conf_dict['cxx20']="${conf_dict['cxx']}"
    conf_dict['cxxflags']="${conf_dict['cflags']}"
    conf_dict['cxx11flags']="${conf_dict['cxxflags']}"
    conf_dict['cxx14flags']="${conf_dict['cxxflags']}"
    conf_dict['cxx17flags']="${conf_dict['cxxflags']}"
    conf_dict['cxx20flags']="${conf_dict['cxxflags']}"
    conf_dict['f77flags']="${conf_dict['fflags']}"
    conf_dict['fcflags']="${conf_dict['fflags']}"
    conf_dict['objc']="${conf_dict['cc']}"
    conf_dict['objcxx']="${conf_dict['cxx']}"
    # This operator is needed to harden library paths for R CRAN binary.
    case "${dict['system']}" in
        '0')
            conf_dict['op']='+='
            ;;
        '1')
            conf_dict['op']='='
            ;;
    esac
    lines+=(
        "AR = ${conf_dict['ar']}"
        "AWK = ${conf_dict['awk']}"
        "BLAS_LIBS = ${conf_dict['blas_libs']}"
        "CC = ${conf_dict['cc']}"
        "CFLAGS = ${conf_dict['cflags']}"
        "CPPFLAGS ${conf_dict['op']} ${conf_dict['cppflags']}"
        "CXX = ${conf_dict['cxx']}"
        "CXX11 = ${conf_dict['cxx11']}"
        "CXX11FLAGS = ${conf_dict['cxx11flags']}"
        "CXX14 = ${conf_dict['cxx14']}"
        "CXX14FLAGS = ${conf_dict['cxx14flags']}"
        "CXX17 = ${conf_dict['cxx17']}"
        "CXX17FLAGS = ${conf_dict['cxx17flags']}"
        "CXX20 = ${conf_dict['cxx20']}"
        "CXX20FLAGS = ${conf_dict['cxx20flags']}"
        "CXXFLAGS = ${conf_dict['cxxflags']}"
        "ECHO = ${conf_dict['echo']}"
        "F77 = ${conf_dict['f77']}"
        "F77FLAGS = ${conf_dict['f77flags']}"
        "FC = ${conf_dict['fc']}"
        "FCFLAGS = ${conf_dict['fcflags']}"
        "FFLAGS = ${conf_dict['fflags']}"
        "FLIBS = ${conf_dict['flibs']}"
        "LAPACK_LIBS = ${conf_dict['lapack_libs']}"
        "LDFLAGS ${conf_dict['op']} ${conf_dict['ldflags']}"
        "OBJC = ${conf_dict['objc']}"
        "OBJCFLAGS = ${conf_dict['objcflags']}"
        "OBJCXX = ${conf_dict['objcxx']}"
        "OBJC_LIBS = ${conf_dict['objc_libs']}"
        "RANLIB = ${conf_dict['ranlib']}"
        "SAFE_FFLAGS = ${conf_dict['safe_fflags']}"
        "SED = ${conf_dict['sed']}"
        "SHELL = ${conf_dict['shell']}"
        "STRIP_SHARED_LIB = ${conf_dict['strip_shared_lib']}"
        "STRIP_STATIC_LIB = ${conf_dict['strip_static_lib']}"
        "YACC = ${conf_dict['yacc']}"
    )
    if koopa_is_macos
    then
        # > local libintl
        # > libintl=(
        # >     '-lintl'
        # >     '-liconv'
        # >     '-Wl,-framework'
        # >     '-Wl,CoreFoundation'
        # > )
        # > conf_dict['libintl']="${libintl[*]}"
        conf_dict['shlib_openmp_cflags']='-Xclang -fopenmp'
        lines+=(
            # > "LIBINTL = ${conf_dict['libintl']}"
            # Can also set 'SHLIB_OPENMP_CXXFLAGS', 'SHLIB_OPENMP_FFLAGS'.
            "SHLIB_OPENMP_CFLAGS = ${conf_dict['shlib_openmp_cflags']}"
        )
    fi
    dict['string']="$(koopa_print "${lines[@]}" | "${app['sort']}")"
    case "${dict['system']}" in
        '0')
            koopa_rm "${dict['file']}"
            koopa_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
        '1')
            koopa_rm --sudo "${dict['file']}"
            koopa_sudo_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
    esac
    unset -v PKG_CONFIG_PATH
    return 0
}
