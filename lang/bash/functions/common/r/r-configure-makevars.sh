#!/usr/bin/env bash

koopa_r_configure_makevars() {
    # """
    # Configure 'Makevars.site' file with compiler settings.
    # @note Updated 2023-05-19.
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
    local -A app bool conf_dict dict
    local -a lines
    koopa_assert_has_args_eq "$#" 1
    lines=()
    app['r']="${1:?}"
    app['sort']="$(koopa_locate_sort --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['openmp']=0
    bool['system']=0
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    if koopa_is_macos && [[ -f '/usr/local/include/omp.h' ]]
    then
        bool['openmp']=1
    fi
    if koopa_is_macos && [[ "${bool['openmp']}" -eq 1 ]]
    then
        # Can also set 'SHLIB_OPENMP_CXXFLAGS', 'SHLIB_OPENMP_FFLAGS'.
        conf_dict['shlib_openmp_cflags']='-Xclang -fopenmp'
        lines+=("SHLIB_OPENMP_CFLAGS = ${conf_dict['shlib_openmp_cflags']}")
    fi
    koopa_is_array_empty "${lines[@]}" && return 0
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['file']="${dict['r_prefix']}/etc/Makevars.site"
    dict['string']="$(koopa_print "${lines[@]}" | "${app['sort']}")"
    koopa_alert_info "Modifying '${dict['file']}'."
    case "${bool['system']}" in
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
