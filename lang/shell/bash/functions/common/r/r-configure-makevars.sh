#!/usr/bin/env bash

koopa_r_configure_makevars() {
    # """
    # Configure 'Makevars.site' file with compiler settings.
    # @note Updated 2022-10-12.
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
    declare -A app
    declare -A dict
    app['r']="${1:?}"
    [[ -x "${app['r']}" ]] || return 1
    dict['system']=0
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    if [[ "${dict['system']}" -eq 1 ]] && koopa_is_docker
    then
        return 0
    fi
    app['ar']='/usr/bin/ar'
    app['awk']="$(koopa_locate_awk --realpath)"
    app['bash']="$(koopa_locate_bash --realpath)"
    app['echo']="$(koopa_locate_echo --realpath)"
    app['gfortran']="$(koopa_locate_gfortran --realpath)"
    app['make']="$(koopa_locate_make --realpath)"
    app['pkg_config']="$(koopa_locate_pkg_config)"
    app['ranlib']='/usr/bin/ranlib'
    app['sed']="$(koopa_locate_sed --realpath)"
    app['sort']="$(koopa_locate_sort)"
    app['strip']='/usr/bin/strip'
    app['tar']="$(koopa_locate_tar --realpath)"
    app['yacc']="$(koopa_locate_yacc --realpath)"
    [[ -x "${app['ar']}" ]] || return 1
    [[ -x "${app['awk']}" ]] || return 1
    [[ -x "${app['bash']}" ]] || return 1
    [[ -x "${app['echo']}" ]] || return 1
    [[ -x "${app['gfortran']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['pkg_config']}" ]] || return 1
    [[ -x "${app['ranlib']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['strip']}" ]] || return 1
    [[ -x "${app['tar']}" ]] || return 1
    [[ -x "${app['yacc']}" ]] || return 1
    dict['arch']="$(koopa_arch)"
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    dict['hdf5']="$(koopa_app_prefix 'hdf5')"
    dict['lapack']="$(koopa_app_prefix 'lapack')"
    dict['openblas']="$(koopa_app_prefix 'openblas')"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['gettext']}" \
        "${dict['hdf5']}" \
        "${dict['lapack']}" \
        "${dict['openblas']}" \
        "${dict['r_prefix']}"
    koopa_add_to_pkg_config_path \
        "${dict['lapack']}/lib/pkgconfig" \
        "${dict['openblas']}/lib/pkgconfig"
    dict['file']="${dict['r_prefix']}/etc/Makevars.site"
    if koopa_is_macos
    then
        # The system clang compiler stack is preferred on macOS. If you attempt
        # to build with GCC, you'll run into a lot of compilation issues with
        # Posit/RStudio packages, which are only optimized for clang currently.
        app['cc']='/usr/bin/clang'
        app['cxx']='/usr/bin/clang++'
    else
        # Some Bioconductor packages (e.g. DiffBind) currently fail to compile
        # unless we use the system GCC stack.
        case "${dict['system']}" in
            '0')
                app['cc']="$(koopa_locate_gcc --realpath)"
                app['cxx']="$(koopa_locate_gcxx --realpath)"
                ;;
            '1')
                app['cc']='/usr/bin/gcc'
                app['cxx']='/usr/bin/g++'
                ;;
        esac
    fi
    [[ -x "${app['cc']}" ]] || return 1
    [[ -x "${app['cxx']}" ]] || return 1
    koopa_alert "Configuring '${dict['file']}'."
    cppflags=()
    ldflags=()
    lines=()
    case "${dict['system']}" in
        '1')
            cppflags+=('-I/usr/local/include')
            ldflags+=('-L/usr/local/lib')
            ;;
    esac
    # Custom pkg-config flags here are incompatible for macOS clang with these
    # packages: fs, httpuv, igraph, nloptr.
    if koopa_is_linux
    then
        # Ensure these values are in sync with Renviron.site file.
        local app_pc_path_arr i key keys pkg_config
        declare -A app_pc_path_arr
        keys=(
            'curl'
            'fontconfig'
            'freetype'
            'fribidi'
            'gdal'
            'geos'
            'glib'
            'graphviz'
            'harfbuzz'
            'icu4c'
            'imagemagick'
            'jpeg'
            'lapack'
            'libgit2'
            'libjpeg-turbo'
            'libpng'
            'libssh2'
            'libtiff'
            # > 'libuv'
            'libxml2'
            'openblas'
            'openssl3'
            'pcre'
            'pcre2'
            'proj'
            'python'
            'readline'
            'sqlite'
            'xz'
            'zlib'
            'zstd'
        )
        for key in "${keys[@]}"
        do
            local prefix
            prefix="$(koopa_app_prefix "$key")"
            koopa_assert_is_dir "$prefix"
            app_pc_path_arr[$key]="$prefix"
        done
        for i in "${!app_pc_path_arr[@]}"
        do
            app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/lib"
        done
        for i in "${!app_pc_path_arr[@]}"
        do
            app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/pkgconfig"
        done
        koopa_assert_is_dir "${app_pc_path_arr[@]}"
        koopa_add_to_pkg_config_path "${app_pc_path_arr[@]}"
        pkg_config=(
            # > 'libglib-2.0'
            # > 'libpcre'
            'fontconfig'
            'freetype2'
            'fribidi'
            'harfbuzz'
            'icu-i18n'
            'icu-uc'
            'libcurl'
            'libjpeg'
            'libpcre2-8'
            'libpng'
            'libtiff-4'
            'libxml-2.0'
            'libzstd'
            'zlib'
        )
        cppflags+=(
            "$("${app['pkg_config']}" --cflags "${pkg_config[@]}")"
        )
        ldflags+=(
            "$("${app['pkg_config']}" --libs-only-L "${pkg_config[@]}")"
        )
    fi
    # NOTE Consider adding libiconv here.
    cppflags+=(
        "-I${dict['bzip2']}/include"
        "-I${dict['hdf5']}/include"
    )
    ldflags+=(
        "-L${dict['bzip2']}/lib"
        "-L${dict['hdf5']}/lib"
    )
    if koopa_is_macos
    then
        cppflags+=("-I${dict['gettext']}/include")
        ldflags+=("-L${dict['gettext']}/lib")
    fi
    # libomp is installed at '/usr/local/lib' for macOS.
    # This is problematic for nloptr but required for data.table.
    koopa_is_macos && ldflags+=('-lomp')
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
    conf_dict['make']="${app['make']}"
    conf_dict['objc_libs']='-lobjc'
    conf_dict['objcflags']="-Wall -g -O2 -fobjc-exceptions \$(LTO)"
    conf_dict['ranlib']="${app['ranlib']}"
    conf_dict['safe_fflags']='-Wall -g -O2 -msse2 -mfpmath=sse'
    conf_dict['sed']="${app['sed']}"
    conf_dict['shell']="${app['bash']}"
    conf_dict['strip_shared_lib']="${app['strip']} -x"
    conf_dict['strip_static_lib']="${app['strip']} -S"
    conf_dict['tar']="${app['tar']}"
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
        "MAKE = ${conf_dict['make']}"
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
        "TAR = ${conf_dict['tar']}"
        "YACC = ${conf_dict['yacc']}"
    )
    if koopa_is_macos
    then
        # R CRAN binary has 'Makeconf' containing (no '-lintl'):
        # > LIBINTL = -Wl,-framework -Wl,CoreFoundation
        local libintl
        libintl=(
            # > '-lintl'
            # > '-liconv'
            '-Wl,-framework'
            '-Wl,CoreFoundation'
        )
        conf_dict['libintl']="${libintl[*]}"
        conf_dict['shlib_openmp_cflags']='-Xclang -fopenmp'
        lines+=(
            "LIBINTL = ${conf_dict['libintl']}"
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
