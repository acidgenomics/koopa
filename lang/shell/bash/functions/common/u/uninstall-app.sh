#!/usr/bin/env bash

# FIXME Currently errors if 'opt' folder doesn't exist.
# This can happen when bootstrapping a system and the first install fails.

koopa_uninstall_app() {
    # """
    # Uninstall an application.
    # @note Updated 2023-04-06.
    # """
    local -A app bool dict
    local -a bin_arr man1_arr
    koopa_assert_is_owner
    bool['quiet']=0
    bool['unlink_in_bin']=''
    bool['unlink_in_man1']=''
    bool['unlink_in_opt']=''
    bool['verbose']=0
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['mode']='shared'
    dict['name']=''
    dict['opt_prefix']="$(koopa_opt_prefix)"
    dict['platform']='common'
    dict['prefix']=''
    dict['uninstaller_bn']=''
    dict['uninstaller_fun']='main'
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
            '--uninstaller='*)
                dict['uninstaller_bn']="${1#*=}"
                shift 1
                ;;
            '--uninstaller')
                dict['uninstaller_bn']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--no-unlink-in-bin')
                bool['unlink_in_bin']=0
                shift 1
                ;;
            '--no-unlink-in-man1')
                bool['unlink_in_man1']=0
                shift 1
                ;;
            '--no-unlink-in-opt')
                bool['unlink_in_opt']=0
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
                bool['verbose']=1
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
            [[ -z "${dict['prefix']}" ]] && \
                dict['prefix']="${dict['app_prefix']}/${dict['name']}"
            [[ -z "${bool['unlink_in_bin']}" ]] && bool['unlink_in_bin']=1
            [[ -z "${bool['unlink_in_man1']}" ]] && bool['unlink_in_man1']=1
            [[ -z "${bool['unlink_in_opt']}" ]] && bool['unlink_in_opt']=1
            ;;
        'system')
            koopa_assert_is_admin
            bool['unlink_in_bin']=0
            bool['unlink_in_man1']=0
            bool['unlink_in_opt']=0
            app['sudo']="$(koopa_locate_sudo)"
            [[ -x "${app['sudo']}" ]] || exit 1
            "${app['sudo']}" -v
            ;;
        'user')
            bool['unlink_in_bin']=0
            bool['unlink_in_man1']=0
            bool['unlink_in_opt']=0
            ;;
    esac
    if [[ -n "${dict['prefix']}" ]]
    then
        if [[ ! -d "${dict['prefix']}" ]]
        then
            koopa_alert_is_not_installed "${dict['name']}" "${dict['prefix']}"
            return 1
        fi
        dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    fi
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -n "${dict['prefix']}" ]]
        then
            koopa_alert_uninstall_start "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_uninstall_start "${dict['name']}"
        fi
    fi
    [[ -z "${dict['uninstaller_bn']}" ]] && \
        dict['uninstaller_bn']="${dict['name']}"
    dict['uninstaller_file']="${dict['koopa_prefix']}/lang/shell/bash/include/\
uninstall/${dict['platform']}/${dict['mode']}/${dict['uninstaller_bn']}.sh"
    if [[ -f "${dict['uninstaller_file']}" ]]
    then
        dict['tmp_dir']="$(koopa_tmp_dir)"
        (
            koopa_cd "${dict['tmp_dir']}"
            # shellcheck source=/dev/null
            source "${dict['uninstaller_file']}"
            koopa_assert_is_function "${dict['uninstaller_fun']}"
            "${dict['uninstaller_fun']}"
        )
        koopa_rm "${dict['tmp_dir']}"
    fi
    if [[ -d "${dict['prefix']}" ]]
    then
        case "${dict['mode']}" in
            'system')
                koopa_rm --sudo "${dict['prefix']}"
                ;;
            *)
                koopa_rm "${dict['prefix']}"
                ;;
        esac
    fi
    case "${dict['mode']}" in
        'shared')
            if [[ "${bool['unlink_in_opt']}" -eq 1 ]]
            then
                koopa_unlink_in_opt "${dict['name']}"
            fi
            # FIXME Rework this as a function.
            if [[ "${bool['unlink_in_bin']}" -eq 1 ]]
            then
                readarray -t bin_arr <<< "$( \
                    koopa_app_json_bin "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if koopa_is_array_non_empty "${bin_arr[@]:-}"
                then
                    koopa_unlink_in_bin "${bin_arr[@]}"
                fi
            fi
            # FIXME Rework this as a function.
            if [[ "${bool['unlink_in_man1']}" -eq 1 ]]
            then
                readarray -t man1_arr <<< "$( \
                    koopa_app_json_man1 "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if koopa_is_array_non_empty "${man1_arr[@]:-}"
                then
                    koopa_unlink_in_man1 "${man1_arr[@]}"
                fi
            fi
            ;;
    esac
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        if [[ -n "${dict['prefix']}" ]]
        then
            koopa_alert_uninstall_success \
                "${dict['name']}" "${dict['prefix']}"
        else
            koopa_alert_uninstall_success "${dict['name']}"
        fi
    fi
    return 0
}
