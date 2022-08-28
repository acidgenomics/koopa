#!/usr/bin/env bash

koopa_r_configure_makevars() {
    # """
    # Configure 'Makevars.site' file with compiler settings.
    # @note Updated 2022-08-28.
    # """
    local app cppflags dict flibs i ldflags libs lines
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['ar']="$(koopa_locate_ar --realpath)"
        ['bash']="$(koopa_locate_bash --realpath)"
        ['dirname']="$(koopa_locate_dirname)"
        ['echo']="$(koopa_locate_echo --realpath)"
        ['r']="${1:?}"
        ['sed']="$(koopa_locate_sed --realpath)"
        ['sort']="$(koopa_locate_sort)"
        ['xargs']="$(koopa_locate_xargs)"
        ['yacc']="$(koopa_locate_yacc --realpath)"
    )
    [[ -x "${app['ar']}" ]] || return 1
    [[ -x "${app['bash']}" ]] || return 1
    [[ -x "${app['dirname']}" ]] || return 1
    [[ -x "${app['echo']}" ]] || return 1
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['sed']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    [[ -x "${app['xargs']}" ]] || return 1
    [[ -x "${app['yacc']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['r_prefix']="$(koopa_r_prefix "${app['r']}")"
        ['system']=0
    )
    dict['file']="${dict['r_prefix']}/etc/Makevars.site"
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    koopa_alert "Configuring '${dict['file']}'."
    lines=()
    if koopa_is_linux
    then
        dict['freetype']="$(koopa_app_prefix 'freetype')"
        lines+=("CPPFLAGS += -I${dict['freetype']}/include/freetype2")
    elif koopa_is_macos
    then
        dict['gcc']="$(koopa_app_prefix 'gcc')"
        # gettext is needed to resolve clang '-lintl' warning.
        dict['gettext']="$(koopa_app_prefix 'gettext')"
        app['fc']="${dict['gcc']}/bin/gfortran"
        # This will cover 'lib' and 'lib64' subdirs.
        # See also 'gcc --print-search-dirs'.
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
        # quadmath not yet supported for aarch64.
        # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=96016
        case "${dict['arch']}" in
            'x86_64')
                flibs+=('-lquadmath')
                ;;
        esac
        # Consider also including '-lemutls_w' here, which is recommended by
        # default macOS build config.
        flibs+=('-lm')
        dict['flibs']="${flibs[*]}"
        cppflags=('-Xclang' '-fopenmp')
        dict['cppflags']="${cppflags[*]}"
        ldflags=(
            "-I${dict['gettext']}/include"
            "-L${dict['gettext']}/lib"
            '-lomp'
        )
        dict['ldflags']="${ldflags[*]}"
        lines+=(
            "CPPFLAGS += ${dict['cppflags']}"
            "FC = ${app['fc']}"
            "FLIBS = ${dict['flibs']}"
            "LDFLAGS += ${dict['ldflags']}"
        )
    fi
    lines+=(
        "AR = ${app['ar']}"
        "ECHO = ${app['echo']}"
        "SED = ${app['sed']}"
        "SHELL = ${app['bash']}"
        "YACC = ${app['yacc']}"
    )
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
