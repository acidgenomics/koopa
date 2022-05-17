#!/usr/bin/env bash

koopa_update_app() {
    # """
    # Update application.
    # @note Updated 2022-05-16.
    # """
    local clean_path_arr dict opt_arr
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A dict=(
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [mode]='shared'
        [name_fancy]=''
        [opt_prefix]="$(koopa_opt_prefix)"
        [platform]='common'
        [prefix]=''
        [quiet]=0
        [set_permissions]=1
        [tmp_dir]="$(koopa_tmp_dir)"
        [update_ldconfig]=0
        [updater_bn]=''
        [updater_fun]='main'
        [verbose]=0
        [version]=''
    )
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    opt_arr=()
    while (("$#"))
    do
        case "$1" in
            '--activate-opt='*)
                opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--activate-opt')
                opt_arr+=("${2:?}")
                shift 2
                ;;
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[name]="${2:?}"
                shift 2
                ;;
            '--name-fancy='*)
                dict[name_fancy]="${1#*=}"
                shift 1
                ;;
            '--name-fancy')
                dict[name_fancy]="${2:?}"
                shift 2
                ;;
            '--platform='*)
                dict[platform]="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict[platform]="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--updater='*)
                dict[updater_bn]="${1#*=}"
                shift 1
                ;;
            '--updater')
                dict[updater_bn]="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict[version]="${1#*=}"
                shift 1
                ;;
            '--version')
                dict[version]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--no-set-permissions')
                dict[set_permissions]=0
                shift 1
                ;;
            '--quiet')
                dict[quiet]=1
                shift 1
                ;;
            '--system')
                dict[mode]='system'
                shift 1
                ;;
            '--user')
                dict[mode]='user'
                shift 1
                ;;
            '--verbose')
                dict[verbose]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${dict[verbose]}" -eq 1 ]] && set -o xtrace
    case "${dict[mode]}" in
        'shared')
            if [[ -z "${dict[prefix]}" ]]
            then
                dict[prefix]="${dict[opt_prefix]}/${dict[name]}"
            fi
            ;;
        'system')
            koopa_assert_is_admin
            koopa_is_linux && dict[update_ldconfig]=1
            ;;
    esac
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_alert_is_not_installed "${dict[name_fancy]}" "${dict[prefix]}"
            return 1
        fi
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    fi
    [[ -z "${dict[updater_bn]}" ]] && dict[updater_bn]="${dict[name]}"
    dict[updater_file]="${dict[installers_prefix]}/${dict[platform]}/\
${dict[mode]}/update-${dict[updater_bn]}.sh"
    koopa_assert_is_file "${dict[updater_file]}"
    # shellcheck source=/dev/null
    source "${dict[updater_file]}"
    koopa_assert_is_function "${dict[updater_fun]}"
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_update_start "${dict[name_fancy]}" "${dict[prefix]}"
        else
            koopa_alert_update_start "${dict[name_fancy]}"
        fi
    fi
    (
        koopa_cd "${dict[tmp_dir]}"
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
        # Activate packages installed in koopa 'opt/' directory.
        if koopa_is_array_non_empty "${opt_arr[@]:-}"
        then
            koopa_activate_opt_prefix "${opt_arr[@]}"
        fi
        if [[ "${dict[update_ldconfig]}" -eq 1 ]]
        then
            koopa_linux_update_ldconfig
        fi
        # shellcheck disable=SC2030
        export UPDATE_PREFIX="${dict[prefix]}"
        "${dict[updater_fun]}"
    )
    koopa_rm "${dict[tmp_dir]}"
    if [[ -d "${dict[prefix]}" ]] && \
        [[ "${dict[set_permissions]}" -eq 1 ]]
    then
        case "${dict[mode]}" in
            'shared')
                koopa_sys_set_permissions \
                    --recursive "${dict[prefix]}"
                ;;
            # > 'user')
            # >     koopa_sys_set_permissions \
            # >         --recursive --user "${dict[prefix]}"
            # >     ;;
        esac
    fi
    if [[ "${dict[update_ldconfig]}" -eq 1 ]]
    then
        koopa_linux_update_ldconfig
    fi
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_update_success "${dict[name_fancy]}" "${dict[prefix]}"
        else
            koopa_alert_update_success "${dict[name_fancy]}"
        fi
    fi
    return 0
}
