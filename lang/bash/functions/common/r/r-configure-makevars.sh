#!/usr/bin/env bash

# FIXME Need to not use sudo permission on linux here:
# /opt/koopa/app/r/4.3.1/lib/R/etc/Makevars.site
# Need to check our boolean flag handling here.

koopa_r_configure_makevars() {
    # """
    # Configure 'Makevars.site' file with compiler settings.
    # @note Updated 2023-10-11.
    #
    # Consider setting 'TCLTK_CPPFLAGS' and 'TCLTK_LIBS' for extra hardened
    # configuration in the future.
    #
    # @section gfortran configuration on macOS:
    #
    # - https://mac.r-project.org/tools/
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
    local -A app app_pc_path_arr bool conf_dict dict
    local -a cppflags keys ldflags lines pkg_config
    local i key
    koopa_assert_has_args_eq "$#" 1
    lines=()
    app['r']="${1:?}"
    app['sort']="$(koopa_locate_sort --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    bool['use_apps']=1
    bool['use_openmp']=0
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    if [[ "${bool['system']}" -eq 1 ]]
    then
        if koopa_is_linux
        then
            bool['use_apps']=0
        elif koopa_is_macos
        then
            bool['use_openmp']=1
        fi
    fi
    if koopa_is_macos && [[ "${bool['use_openmp']}" -eq 1 ]]
    then
        koopa_assert_is_file '/usr/local/include/omp.h'
        # Can also set 'SHLIB_OPENMP_CXXFLAGS', 'SHLIB_OPENMP_FFLAGS'.
        conf_dict['shlib_openmp_cflags']='-Xclang -fopenmp'
        lines+=("SHLIB_OPENMP_CFLAGS = ${conf_dict['shlib_openmp_cflags']}")
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        app['ar']="$(koopa_locate_ar --only-system)"
        app['awk']="$(koopa_locate_awk)"
        app['bash']="$(koopa_locate_bash)"
        app['cc']="$(koopa_locate_cc --only-system)"
        app['cxx']="$(koopa_locate_cxx --only-system)"
        app['echo']="$(koopa_locate_echo)"
        if koopa_is_macos
        then
            app['gfortran']='/opt/gfortran/bin/gfortran'
        else
            # FIXME Add support for locating this on macOS.
            app['gfortran']="$(koopa_locate_gfortran --only-system)"
        fi
        app['make']="$(koopa_locate_make)"
        app['pkg_config']="$(koopa_locate_pkg_config)"
        app['ranlib']="$(koopa_locate_ranlib --only-system)"
        app['sed']="$(koopa_locate_sed)"
        app['strip']="$(koopa_locate_strip)"
        app['tar']="$(koopa_locate_tar)"
        app['yacc']="$(koopa_locate_yacc)"
        koopa_assert_is_executable "${app[@]}"
        koopa_is_macos && dict['gettext']="$(koopa_app_prefix 'gettext')"
        dict['openssl3']="$(koopa_app_prefix 'openssl3')"
        # Ensure these values are in sync with 'Renviron.site' file.
        ! koopa_is_macos && keys+=('bzip2')
        keys+=(
            'cairo'
            'curl'
            'fontconfig'
            'freetype'
            'fribidi'
            'gdal'
            'geos'
            'glib'
            'graphviz'
            'harfbuzz'
            'hdf5'
            'icu4c'
            'imagemagick'
            'libffi'
            'libgit2'
            'libjpeg-turbo'
            'libpng'
            'libssh2'
            'libtiff'
            'libxml2'
            'openssl3'
            'pcre'
            'pcre2'
            'pixman'
            'proj'
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
        pkg_config+=(
            'fontconfig'
            'freetype2'
            'fribidi'
            'harfbuzz'
            'hdf5'
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
            "-I${dict['openssl3']}/include"
        )
        ldflags+=(
            "$("${app['pkg_config']}" --libs-only-L "${pkg_config[@]}")"
            "-L${dict['openssl3']}/lib"
        )
        if koopa_is_macos
        then
            cppflags+=("-I${dict['gettext']}/include")
            ldflags+=("-L${dict['gettext']}/lib")
            # The new ld linker in Xcode CLT 15 breaks a lot of stuff, so
            # reverting to classic mode here.
            dict['clt_maj_ver']="$(koopa_macos_xcode_clt_major_version)"
            if [[ "${dict['clt_maj_ver']}" -ge 15 ]]
            then
                ldflags+=('-Wl,-ld_classic')
            fi
            if [[ "${bool['use_openmp']}" -eq 1 ]]
            then
                ldflags+=('-lomp')
            fi
        fi
        conf_dict['ar']="${app['ar']}"
        conf_dict['awk']="${app['awk']}"
        conf_dict['cc']="${app['cc']}"
        conf_dict['cflags']="-Wall -g -O2 \$(LTO)"
        conf_dict['cppflags']="${cppflags[*]}"
        conf_dict['cxx']="${app['cxx']} -std=gnu++14"
        conf_dict['echo']="${app['echo']}"
        conf_dict['f77']="${app['gfortran']}"
        conf_dict['fc']="${app['gfortran']}"
        conf_dict['fflags']="-Wall -g -O2 \$(LTO_FC)"
        conf_dict['flibs']="$(koopa_r_gfortran_libs)"
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
        if [[ "${bool['system']}" -eq 1 ]]
        then
            conf_dict['op']='='
        else
            conf_dict['op']='+='
        fi
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
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['file']="${dict['r_prefix']}/etc/Makevars.site"
    if koopa_is_linux && \
        [[ "${bool['system']}" -eq 1 ]] && \
        [[ -f "${dict['file']}" ]]
    then
        koopa_alert_info "Deleting '${dict['file']}'."
        koopa_rm --sudo "${dict['file']}"
        return 0
    fi
    koopa_is_array_empty "${lines[@]}" && return 0
    dict['string']="$(koopa_print "${lines[@]}" | "${app['sort']}")"
    koopa_alert_info "Modifying '${dict['file']}'."
    if [[ "${bool['system']}" -eq 1 ]]
    then
        koopa_rm --sudo "${dict['file']}"
        koopa_sudo_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    else
        koopa_rm "${dict['file']}"
        koopa_write_string \
            --file="${dict['file']}" \
            --string="${dict['string']}"
    fi
    unset -v PKG_CONFIG_PATH
    return 0
}
