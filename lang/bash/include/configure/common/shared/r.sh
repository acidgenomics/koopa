#!/usr/bin/env bash

# FIXME This is setting our build from source as system on Ubuntu 22....

main() {
    # """
    # Configure R.
    # @note Updated 2023-10-11.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    #
    # @seealso
    # - R CMD config
    # - https://cran.r-project.org/bin/linux/debian/
    # """
    local -A app bool dict
    koopa_assert_has_args_le "$#" 1
    app['r']="${1:-}"
    [[ -z "${app['r']}" ]] && app['r']="$(koopa_locate_r)"
    koopa_assert_is_executable "${app[@]}"
    app['r']="$(koopa_realpath "${app['r']}")"
    bool['system']=0
    if ! koopa_is_koopa_app "${app['r']}"
    then
        koopa_print "${app['r']}"
        koopa_stop 'FIXME NOOOO BAD UBUNTU'
        koopa_assert_is_admin
        bool['system']=1
    fi
    dict['name']='r'
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['site_library']="${dict['r_prefix']}/site-library"
    koopa_alert_configure_start "${dict['name']}" "${app['r']}"
    koopa_assert_is_dir "${dict['r_prefix']}"
    koopa_r_configure_environ "${app['r']}"
    koopa_r_configure_ldpaths "${app['r']}"
    koopa_r_configure_makevars "${app['r']}"
    koopa_r_copy_files_into_etc "${app['r']}"
    koopa_r_configure_java "${app['r']}"
    case "${bool['system']}" in
        '0')
            if [[ -L "${dict['site_library']}" ]]
            then
                koopa_rm "${dict['site_library']}"
            fi
            koopa_sys_mkdir "${dict['site_library']}"
            ;;
        '1')
            dict['group']="$(koopa_admin_group_name)"
            dict['user']='root'
            # > dict['user']="$(koopa_user_name)"
            if [[ -L "${dict['site_library']}" ]]
            then
                koopa_rm --sudo "${dict['site_library']}"
            fi
            koopa_mkdir --sudo "${dict['site_library']}"
            koopa_chmod --sudo '0775' "${dict['site_library']}"
            koopa_chown --sudo --recursive \
                "${dict['user']}:${dict['group']}" \
                "${dict['site_library']}"
            koopa_chmod --sudo --recursive \
                'g+rw' "${dict['site_library']}"
            # Ensure default site-library for Debian/Ubuntu is writable.
            dict['site_library_2']='/usr/local/lib/R/site-library'
            if [[ -d "${dict['site_library_2']}" ]]
            then
                koopa_chmod --sudo '0775' "${dict['site_library_2']}"
                koopa_chown --sudo --recursive \
                    "${dict['user']}:${dict['group']}" \
                    "${dict['site_library_2']}"
                koopa_chmod --sudo --recursive \
                    'g+rw' "${dict['site_library_2']}"
            fi
            ;;
    esac
    koopa_r_migrate_non_base_packages "${app['r']}"
    # > koopa_sys_set_permissions --recursive "${dict['site_library']}"
    koopa_alert_configure_success "${dict['name']}" "${app['r']}"
    if [[ "${bool['system']}" -eq 1 ]] && koopa_is_linux
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
