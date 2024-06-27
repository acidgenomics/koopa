#!/usr/bin/env bash

main() {
    # """
    # Configure R.
    # @note Updated 2024-06-27.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    #
    # @seealso
    # - R CMD config
    # - https://cran.r-project.org/bin/linux/debian/
    # """
    local -A app bool dict
    local -a deps
    koopa_assert_has_args_le "$#" 1
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    koopa_assert_is_executable "${app[@]}"
    app['r']="$(koopa_realpath "${app['r']}")"
    bool['system']=0
    if ! koopa_is_koopa_app "${app['r']}"
    then
        koopa_assert_is_admin
        bool['system']=1
    fi
    dict['name']='r'
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['site_library']="${dict['r_prefix']}/site-library"
    if [[ "${bool['system']}" -eq 1 ]]
    then
        dict['admin_user']="$(koopa_admin_user_name)"
        dict['admin_group']="$(koopa_admin_group_name)"
        dict['user']="$(koopa_user_name)"
        dict['group']="$(koopa_group_name)"
    fi
    koopa_alert_configure_start "${dict['name']}" "${app['r']}"
    koopa_assert_is_dir "${dict['r_prefix']}"
    if [[ "${bool['system']}" -eq 1 ]] && koopa_is_macos
    then
        readarray -t deps <<< "$(koopa_app_dependencies 'r')"
        koopa_dl 'R dependencies' "$(koopa_to_string "${deps[@]}")"
        koopa_cli_install "${deps[@]}"

    fi
    if [[ "${bool['system']}" -eq 1 ]]
    then
        dict['local_r']='/usr/local/lib/R'
        if [[ -d "${dict['local_r']}" ]]
        then
            koopa_rm --sudo "${dict['local_r']}"
        fi
        koopa_mkdir --sudo "${dict['site_library']}"
        koopa_chmod --sudo '0775' "${dict['site_library']}"
        koopa_chown --sudo --recursive \
            "${dict['user']}:${dict['group']}" \
            "${dict['site_library']}"
        koopa_chmod --sudo --recursive \
            'g+rw' "${dict['site_library']}"
    else
        koopa_mkdir "${dict['site_library']}"
    fi
    koopa_r_configure_environ "${app['r']}"
    koopa_r_configure_ldpaths "${app['r']}"
    koopa_r_configure_makevars "${app['r']}"
    koopa_r_copy_files_into_etc "${app['r']}"
    koopa_r_configure_java "${app['r']}"
    koopa_r_migrate_non_base_packages "${app['r']}"
    if [[ "${bool['system']}" -eq 1 ]]
    then
        koopa_chown --sudo --recursive \
            "${dict['user']}:${dict['group']}" \
            "${dict['site_library']}"
        koopa_chmod --sudo --recursive \
            'g+rw' "${dict['site_library']}"
        if koopa_is_linux
        then
            app['rstudio_server']="$( \
                koopa_linux_locate_rstudio_server --allow-missing \
            )"
            if [[ -x "${app['rstudio_server']}" ]]
            then
                koopa_linux_configure_system_rstudio_server
            fi
        fi
    fi
    koopa_alert_configure_success "${dict['name']}" "${app['r']}"
    return 0
}
