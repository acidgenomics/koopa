#!/usr/bin/env bash

koopa_configure_r() {
    # """
    # Update R configuration.
    # @note Updated 2023-04-03.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    #
    # @seealso
    # - R CMD config
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app dict
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    [[ -x "${app['r']}" ]] || return 1
    app['r']="$(koopa_realpath "${app['r']}")"
    dict['name']='r'
    dict['system']=0
    if ! koopa_is_koopa_app "${app['r']}"
    then
        koopa_assert_is_admin
        dict['system']=1
    fi
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['site_library']="${dict['r_prefix']}/site-library"
    koopa_alert_configure_start "${dict['name']}" "${app['r']}"
    koopa_assert_is_dir "${dict['r_prefix']}"
    if koopa_is_macos && [[ ! -f '/usr/local/include/omp.h' ]]
    then
        koopa_stop \
            "'libomp' is not installed." \
            "Run 'koopa install system openmp' to resolve."
    fi
    koopa_r_link_files_in_etc "${app['r']}"
    koopa_r_configure_environ "${app['r']}"
    koopa_r_configure_makevars "${app['r']}"
    koopa_r_configure_ldpaths "${app['r']}"
    koopa_r_configure_java "${app['r']}"
    case "${dict['system']}" in
        '0')
            if [[ -L "${dict['site_library']}" ]]
            then
                koopa_rm "${dict['site_library']}"
            fi
            koopa_sys_mkdir "${dict['site_library']}"
            ;;
        '1')
            dict['group']="$(koopa_admin_group_name)"
            dict['user']="$(koopa_user_name)"
            if [[ -L "${dict['site_library']}" ]]
            then
                koopa_rm --sudo "${dict['site_library']}"
            fi
            koopa_mkdir --sudo "${dict['site_library']}"
            koopa_chmod --sudo '0775' "${dict['site_library']}"
            koopa_chown --sudo --recursive \
                "${dict['user']}:${dict['group']}" \
                "${dict['site_library']}"
            # Ensure default site-library for Debian/Ubuntu is writable.
            dict['site_library_2']='/usr/local/lib/R/site-library'
            if [[ -d "${dict['site_library_2']}" ]]
            then
                koopa_chmod --sudo '0775' "${dict['site_library_2']}"
                koopa_chown --sudo --recursive \
                    "${dict['user']}:${dict['group']}" \
                    "${dict['site_library_2']}"
            fi
            koopa_r_configure_makeconf "${app['r']}"
            koopa_r_rebuild_docs "${app['r']}"
            ;;
    esac
    # > koopa_sys_set_permissions --recursive "${dict['site_library']}"
    koopa_alert_configure_success "${dict['name']}" "${app['r']}"
    if [[ "${dict['system']}" -eq 1 ]] && koopa_is_linux
    then
        app['rstudio_server']="$( \
            koopa_linux_locate_rstudio_server --allow-missing \
        )"
        if [[ -x "${app['rstudio_server']}" ]]
        then
            koopa_linux_configure_system_rstudio_server
        fi
    fi
    return 0
}
