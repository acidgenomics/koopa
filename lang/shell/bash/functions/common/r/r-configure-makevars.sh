#!/usr/bin/env bash

koopa_r_configure_makevars() {
    # """
    # Configure 'Makevars.site' file with compiler settings.
    # @note Updated 2022-08-29.

    # Consider removing '/usr/local' paths in 'CPPFLAGS', 'LDFLAGS', and 'LIBS'
    # for R CRAN binary. This helps avoid unwanted conflicts with Homebrew.
    #
    # Consider setting 'TCLTK_CPPFLAGS' and 'TCLTK_LIBS' for extra hardened
    # configuration.

    # @seealso
    # - /opt/koopa/opt/r/lib/R/etc/Makeconf
    # - /Library/Frameworks/R.framework/Versions/Current/Resources/etc/Makeconf
    # """
    local app conf_dict dict i
    local blas_libs cppflags flibs gcc_libs ldflags lines
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['ar']='/usr/bin/ar'
        ['bash']="$(koopa_locate_bash --realpath)"
        ['dirname']="$(koopa_locate_dirname)"
        ['echo']="$(koopa_locate_echo --realpath)"
        ['fc']="$(koopa_locate_gfortran --realpath)"
        ['jar']="$(koopa_locate_jar --realpath)"
        ['java']="$(koopa_locate_java --realpath)"
        ['javac']="$(koopa_locate_javac --realpath)"
        ['r']="${1:?}"
        ['ranlib']='/usr/bin/ranlib'
        ['sed']="$(koopa_locate_sed --realpath)"
        ['sort']="$(koopa_locate_sort)"
        ['strip']='/usr/bin/strip'
        ['xargs']="$(koopa_locate_xargs)"
        ['yacc']="$(koopa_locate_yacc --realpath)"
    )
    # FIXME Need to link to GCC on Linux.
    if koopa_is_macos
    then
        app['cc']='/usr/bin/clang'
        app['cxx']='/usr/bin/clang++'
    fi
    [[ -x "${app['ar']}" ]] || return 1
    [[ -x "${app['bash']}" ]] || return 1
    [[ -x "${app['cc']}" ]] || return 1
    [[ -x "${app['cxx']}" ]] || return 1
    [[ -x "${app['dirname']}" ]] || return 1
    [[ -x "${app['echo']}" ]] || return 1
    [[ -x "${app['fc']}" ]] || return 1
    [[ -x "${app['jar']}" ]] || return 1
    [[ -x "${app['java']}" ]] || return 1
    [[ -x "${app['javac']}" ]] || return 1
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['ranlib']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['strip']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    [[ -x "${app['yacc']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['freetype']="$(koopa_app_prefix 'freetype')"
        ['gcc']="$(koopa_app_prefix 'gcc')"
        ['gettext']="$(koopa_app_prefix 'gettext')"
        ['openblas']="$(koopa_app_prefix 'openblas')"
        ['openjdk']="$(koopa_app_prefix 'openjdk')"
        ['r_prefix']="$(koopa_r_prefix "${app['r']}")"
        ['system']=0
    )
    koopa_assert_is_dir \
        "${dict['freetype']}" \
        "${dict['gcc']}" \
        "${dict['gettext']}" \
        "${dict['openblas']}" \
        "${dict['openjdk']}" \
        "${dict['r_prefix']}"
    dict['file']="${dict['r_prefix']}/etc/Makevars.site"
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    koopa_alert "Configuring '${dict['file']}'."
    blas_libs=()
    cppflags=()
    flibs=()
    ldflags=()
    # > local libs
    # > libs=()
    lines=()
    # FIXME We should set this from openblas pkgconfig instead.
    blas_libs=(
        # > '-L"$(R_HOME)/lib$(R_ARCH)"'
        # > '-lRblas' 
        "-L${dict['openblas']}/lib"
        '-lopenblas'
    )
    # Locate gfortran library paths (from GCC). This will cover 'lib' and
    # 'lib64' subdirs. See also 'gcc --print-search-dirs'.
    readarray -t gcc_libs <<< "$( \
        koopa_find \
            --prefix="${dict['gcc']}" \
            --pattern='*.a' \
            --type 'f' \
        | "${app['xargs']}" -I '{}' "${app['dirname']}" '{}' \
        | "${app['sort']}" --unique \
    )"
    koopa_assert_is_array_non_empty "${gcc_libs[@]:-}"
    for i in "${!gcc_libs[@]}"
    do
        flibs+=("-L${gcc_libs[$i]}")
    done
    # Consider also including '-lemutls_w' here, which is recommended by
    # default macOS build config.
    flibs+=('-lgfortran' '-lm')
    # quadmath is not yet supported for aarch64.
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=96016
    case "${dict['arch']}" in
        'x86_64')
            flibs+=('-lquadmath')
            ;;
    esac
    cppflags+=(
        # > '-I/usr/local/include'
        "-I${dict['freetype']}/include/freetype2"
    )
    # FIXME What if we set LIBINTL instead? Can we then remove the GETTEXT
    # Call here?
    # gettext is needed to resolve clang '-lintl' warning.
    ldflags+=(
        # > '-L/usr/local/lib'
        "-I${dict['gettext']}/include"
        "-L${dict['gettext']}/lib"
        '-lomp'
    )
    libs+=(
        # > '-L/usr/local/lib'
        '-lpcre2-8'
        '-llzma'
        '-lbz2'
        '-lz'
        '-licucore'
        '-ldl'
        '-lm'
        '-liconv'
    )
    conf_dict['ar']="${app['ar']}"
    conf_dict['blas_libs']="${blas_libs[*]}"
    conf_dict['cc']="${app['cc']}"
    # NOTE Consider using '-O3' instead of '-O2' here.
    conf_dict['cflags']="-Wall -g -O2 \$(LTO)"
    conf_dict['cpicflags']='-fPIC'
    conf_dict['cppflags']="${cppflags[*]}"
    conf_dict['c_visibility']=''
    conf_dict['cxx']="${app['cxx']} -std=gnu++14"
    conf_dict['echo']="${app['echo']}"
    conf_dict['fc']="${app['fc']}"
    conf_dict['fflags']="-Wall -g -O2 \$(LTO_FC)"
    conf_dict['flibs']="${flibs[*]}"
    conf_dict['jar']="${app['jar']}"
    conf_dict['java']="${app['java']}"
    conf_dict['java_home']="${dict['openjdk']}"
    conf_dict['javac']="${app['javac']}"
    conf_dict['ldflags']="${ldflags[*]}"
    conf_dict['libs']="${libs[*]}"
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

    # FIXME Use pkg-config to configure:
    # pkg-config --libs /opt/koopa/app/lapack/3.10.1/lib/pkgconfig/lapack.pc
    conf_dict['lapack_libs']="-L/opt/koopa/app/lapack/3.10.1/lib -llapack"

    # FIXME Use pkg-config to configure:
    # pkg-config --libs /opt/koopa/app/tcl-tk/8.6.12/lib/pkgconfig/tcl.pc
    # -L/opt/koopa/app/tcl-tk/8.6.12/lib -ltcl8.6 -ltclstub8.6
    # FIXME Note that this requires tcl.pc to be in path.
    # pkg-config --libs /opt/koopa/app/tcl-tk/8.6.12/lib/pkgconfig/tk.pc
    # Refer to Libs.private value in tk.pc.
    # NOTE Our build from source doesn't include '-ltclstub8.6'.
    # FIXME Consider installing tcl and tk separately.
    conf_dict['tcltk_cppflags']="-I/opt/koopa/app/tcl-tk/8.6.12/include -I/opt/koopa/app/tcl-tk/8.6.12/include  -I/usr/X11R6/include"
    conf_dict['tcltk_libs']="-L/opt/koopa/app/tcl-tk/8.6.12/lib -ltcl8.6 -L/opt/koopa/app/tcl-tk/8.6.12/lib -ltk8.6 -L/usr/X11R6/lib -lX11 -Wl,-weak-lXss -lXext"

    # These are values that inherit from other values in the dictionary.
    conf_dict['cxx11']="${conf_dict['cxx']}"
    conf_dict['cxx11flags']="${conf_dict['cxxflags']}"
    conf_dict['cxx14']="${conf_dict['cxx']}"
    conf_dict['cxx14flags']="${conf_dict['cxxflags']}"
    conf_dict['cxx17']="${conf_dict['cxx']}"
    conf_dict['cxx17flags']="${conf_dict['cxxflags']}"
    conf_dict['cxx20']="${conf_dict['cxx']}"
    conf_dict['cxx20flags']="${conf_dict['cxxflags']}"
    conf_dict['cxxflags']="${conf_dict['cflags']}"
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
        "FC = ${conf_dict['fc']}"
        "FCFLAGS = ${conf_dict['fcflags']}"
        "FFLAGS = ${conf_dict['fflags']}"
        "FLIBS = ${conf_dict['flibs']}"
        "JAR = ${conf_dict['jar']}"
        "JAVA = ${conf_dict['java']}"
        "JAVAC = ${conf_dict['javac']}"
        "JAVA_HOME = ${conf_dict['java_home']}"
        "LAPACK_LIBS = ${conf_dict['lapack_libs']}"
        "LDFLAGS ${conf_dict['op']} ${conf_dict['ldflags']}"
        "LIBS = ${conf_dict['libs']}"
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
        "TCLTK_CPPFLAGS = ${conf_dict['tcltk_cppflags']}"
        "TCLTK_LIBS = ${conf_dict['tcltk_libs']}"
        "YACC = ${conf_dict['yacc']}"
    )
    if koopa_is_macos
    then
        # FIXME Can we get this from gettext pkgconfig instead?
        conf_dict['libintl']='-lintl -liconv -Wl,-framework -Wl,CoreFoundation'
        conf_dict['shlib_openmp_cflags']='-Xclang -fopenmp'
        lines+=(
            "LIBINTL = ${conf_dict['libintl']}"
            "SHLIB_OPENMP_CFLAGS = ${conf_dict['shlib_openmp_cflags']}"
            # > 'SHLIB_OPENMP_CXXFLAGS ='
            # > 'SHLIB_OPENMP_FFLAGS ='
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
    return 0
}
