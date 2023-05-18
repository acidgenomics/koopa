#!/usr/bin/env bash

koopa_r_configure_makevars() {
    # """
    # Configure 'Makevars.site' file with compiler settings.
    # @note Updated 2023-05-18.
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
    local -A app app_pc_path_arr conf_dict dict
    local -a cppflags keys libintl ldflags lines pkg_config
    local i key
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    app['sort']="$(koopa_locate_sort --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['system']=0
    dict['use_apps']=1
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    [[ "${dict['system']}" -eq 1 ]] && dict['use_apps']=0
    if [[ "${dict['use_apps']}" -eq 1 ]]
    then
        if koopa_is_linux
        then
            app['cc']='/usr/bin/gcc'
            app['cxx']='/usr/bin/g++'
        elif koopa_is_macos
        then
            app['cc']='/usr/bin/clang'
            app['cxx']='/usr/bin/clang++'
        fi
        app['awk']="$(koopa_locate_awk)"
        app['bash']="$(koopa_locate_bash)"
        app['echo']="$(koopa_locate_echo)"
        app['gfortran']="$(koopa_locate_gfortran)"
        app['make']="$(koopa_locate_make)"
        app['pkg_config']="$(koopa_locate_pkg_config)"
        app['sed']="$(koopa_locate_sed)"
        app['tar']="$(koopa_locate_tar)"
        app['yacc']="$(koopa_locate_yacc)"
        dict['bzip2']="$(koopa_app_prefix 'bzip2')"
        dict['gettext']="$(koopa_app_prefix 'gettext')"
        dict['hdf5']="$(koopa_app_prefix 'hdf5')"
        dict['libjpeg']="$(koopa_app_prefix 'libjpeg-turbo')"
        dict['libpng']="$(koopa_app_prefix 'libpng')"
        dict['openssl3']="$(koopa_app_prefix 'openssl3')"
        koopa_add_to_pkg_config_path \
            "${dict['libjpeg']}/lib/pkgconfig" \
            "${dict['libpng']}/lib/pkgconfig"
    fi
    koopa_assert_is_executable "${app[@]}"
    cppflags=()
    ldflags=()
    lines=()
    # > case "${dict['system']}" in
    # >     '1')
    # >         cppflags+=('-I/usr/local/include')
    # >         ldflags+=('-L/usr/local/lib')
    # >         ;;
    # > esac
    if [[ "${dict['use_apps']}" -eq 1 ]]
    then
        # Custom pkg-config flags here are incompatible for macOS clang with
        # these packages: fs, httpuv, igraph, nloptr.
        if koopa_is_linux
        then
            # Ensure these values are in sync with Renviron.site file.
            keys=(
                'cairo'
                'curl7'
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
                # > 'jpeg'
                'libffi'
                'libgit2'
                'libjpeg-turbo'
                'libpng'
                'libssh2'
                'libtiff'
                # > 'libuv'
                'libxml2'
                'openssl3'
                'pcre'
                'pcre2'
                'pixman'
                'proj'
                'python3.11'
                'readline'
                'sqlite'
                'xorg-libice'
                'xorg-libpthread-stubs'
                'xorg-libsm'
                'xorg-libx11'
                'xorg-libxau'
                'xorg-libxcb'
                'xorg-libxdmcp'
                'xorg-libxext'
                'xorg-libxrandr'
                'xorg-libxrender'
                'xorg-libxt'
                'xorg-xorgproto'
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
                case "$i" in
                    'xorg-xorgproto')
                        app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/\
share/pkgconfig"
                        ;;
                    *)
                        app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/\
lib/pkgconfig"
                        ;;
                esac
            done
            koopa_assert_is_dir "${app_pc_path_arr[@]}"
            koopa_add_to_pkg_config_path "${app_pc_path_arr[@]}"
            pkg_config=(
                # > 'cairo'
                # > 'libffi'
                # > 'libglib-2.0'
                # > 'libpcre'
                # > 'pixman-1'
                # > 'xcb-shm'
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
            "-I${dict['libjpeg']}/include"
            "-I${dict['libpng']}/include"
            "-I${dict['openssl3']}/include"
        )
        ldflags+=(
            "-L${dict['bzip2']}/lib"
            "-L${dict['hdf5']}/lib"
            "-L${dict['libjpeg']}/lib"
            "-L${dict['libpng']}/lib"
            "-L${dict['openssl3']}/lib"
        )
        if koopa_is_macos
        then
            cppflags+=("-I${dict['gettext']}/include")
            ldflags+=("-L${dict['gettext']}/lib")
            # libomp is installed at '/usr/local/lib' for macOS.
            ldflags+=('-lomp')
        fi
        conf_dict['ar']="${app['ar']}"
        conf_dict['awk']="${app['awk']}"
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
    fi
    if koopa_is_macos
    then
        # R CRAN binary has 'Makeconf' containing (no '-lintl'):
        # > LIBINTL = -Wl,-framework -Wl,CoreFoundation
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
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['file']="${dict['r_prefix']}/etc/Makevars.site"
    dict['string']="$(koopa_print "${lines[@]}" | "${app['sort']}")"
    koopa_alert_info "Modifying '${dict['file']}'."
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
