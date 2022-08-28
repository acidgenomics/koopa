#!/usr/bin/env bash

koopa_update_app() {
    # """
    # Update application.
    # @note Updated 2022-08-15.
    # """
    local bool clean_path_arr dict
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A bool=(
        ['prefix_check']=1
        ['quiet']=0
        ['set_permissions']=1
        ['update_ldconfig']=0
        ['verbose']=0
    )
    declare -A dict=(
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['mode']='shared'
        ['name']=''
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['platform']='common'
        ['prefix']=''
        ['tmp_dir']="$(koopa_tmp_dir)"
        ['updater_bn']=''
        ['updater_fun']='main'
        ['version']=''
    )
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    while (("$#"))
    do
        case "$1" in
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--updater='*)
                dict['updater_bn']="${1#*=}"
                shift 1
                ;;
            '--updater')
                dict['updater_bn']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--no-prefix-check')
                bool['prefix_check']=0
                shift 1
                ;;
            '--no-set-permissions')
                bool['set_permissions']=0
                shift 1
                ;;
            '--quiet')
                bool['quiet']=1
                shift 1
                ;;
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            '--verbose')
                dict['verbose']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set '--name' "${dict['name']}"
    [[ "${bool['verbose']}" -eq 1 ]] && set -o xtrace
    case "${dict['mode']}" in
        'shared')
            if [[ -z "${dict['prefix']}" ]]
            then
                dict['prefix']="${dict['opt_prefix']}/${dict['name']}"
            fi
            ;;
        'system')
            koopa_assert_is_admin
            koopa_is_linux && bool['update_ldconfig']=1
            ;;
    esac
    if [[ -n "${dict['prefix']}" ]]
    then
        if [[ ! -d "${dict['prefix']}" ]] && \
            [[ "${bool['prefix_check']}" -eq 1 ]]
        then
            koopa_alert_is_not_installed "${dict['name']}" "${dict['prefix']}"
            return 1
        fi
        dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    fi
    [[ -z "${dict['updater_bn']}" ]] && dict['updater_bn']="${dict['name']}"
    dict['updater_file']="${dict['koopa_prefix']}/lang/shell/bash/include/\
update/${dict['platform']}/${dict['mode']}/${dict['updater_bn']}.sh"
    koopa_assert_is_file "${dict['updater_file']}"
    # shellcheck source=/dev/null
    source "${dict['updater_file']}"
    koopa_assert_is_function "${dict['updater_fun']}"
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -d "${dict['prefix']}" ]]
        then
            koopa_alert_update_start "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_update_start "${dict['name']}"
        fi
    fi
    (
        koopa_cd "${dict['tmp_dir']}"
        unset -v \
            CFLAGS \
            CPPFLAGS \
            LDFLAGS \
            LDLIBS \
            LD_LIBRARY_PATH \
            PKG_CONFIG_PATH
        PATH="$(koopa_paste --sep=':' "${clean_path_arr[@]}")"
        export PATH
        if koopa_is_linux && \
            [[ -x '/usr/bin/pkg-config' ]]
        then
            koopa_add_to_pkg_config_path_2 \
                '/usr/bin/pkg-config'
        fi
        if [[ "${bool['update_ldconfig']}" -eq 1 ]]
        then
            koopa_linux_update_ldconfig
        fi
        # shellcheck disable=SC2030
        export UPDATE_PREFIX="${dict['prefix']}"
        "${dict['updater_fun']}"
    )
    koopa_rm "${dict['tmp_dir']}"
    if [[ -d "${dict['prefix']}" ]] && \
        [[ "${bool['set_permissions']}" -eq 1 ]]
    then
        case "${dict['mode']}" in
            'shared')
                koopa_sys_set_permissions \
                    --recursive "${dict['prefix']}"
                ;;
            # > 'user')
            # >     koopa_sys_set_permissions \
            # >         --recursive --user "${dict['prefix']}"
            # >     ;;
        esac
    fi
    if [[ "${bool['update_ldconfig']}" -eq 1 ]]
    then
        koopa_linux_update_ldconfig
    fi
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -d "${dict['prefix']}" ]]
        then
            koopa_alert_update_success "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_update_success "${dict['name']}"
        fi
    fi
    return 0
}
