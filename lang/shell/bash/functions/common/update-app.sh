#!/usr/bin/env bash

koopa_update_app() { # {{{1
    # """
    # Update application.
    # @note Updated 2022-02-25.
    # """
    local clean_path_arr dict homebrew_opt_arr opt_arr pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A dict=(
        [homebrew_opt]=''
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [name_fancy]=''
        [opt]=''
        [opt_prefix]="$(koopa_opt_prefix)"
        [platform]='common'
        [prefix]=''
        [quiet]=0
        [shared]=0
        [system]=0
        [tmp_dir]="$(koopa_tmp_dir)"
        [updater]=''
        [version]=''
    )
    clean_path_arr=('/usr/bin' '/bin' '/usr/sbin' '/sbin')
    homebrew_opt_arr=()
    opt_arr=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--homebrew-opt='*)
                homebrew_opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--homebrew-opt')
                homebrew_opt_arr+=("${2:?}")
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
            '--opt='*)
                opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--opt')
                opt_arr+=("${2:?}")
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
                dict[updater]="${1#*=}"
                shift 1
                ;;
            '--updater')
                dict[updater]="${2:?}"
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
            '--quiet')
                dict[quiet]=1
                shift 1
                ;;
            '--system')
                dict[system]=1
                shift 1
                ;;
            '--verbose')
                set -o xtrace
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    [[ -z "${dict[name_fancy]}" ]] && dict[name_fancy]="${dict[name]}"
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_warn "${dict[name_fancy]} is not installed \
at '${dict[prefix]}'."
            return 1
        fi
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
        if koopa_str_detect_regex \
            --string="${dict[prefix]}" \
            --pattern="^${dict[koopa_prefix]}"
        then
            dict[shared]=1
        else
            dict[shared]=0
        fi
    else
        if koopa_is_shared_install
        then
            dict[shared]=1
        else
            dict[shared]=0
        fi
    fi
    if [[ "${dict[system]}" -eq 1 ]]
    then
        dict[shared]=0
    fi
    if [[ "${dict[shared]}" -eq 1 ]] || [[ "${dict[system]}" -eq 1 ]]
    then
        koopa_assert_is_admin
    fi
    [[ -z "${dict[updater]}" ]] && dict[updater]="${dict[name]}"
    dict[updater]="$(koopa_snake_case_simple "update_${dict[updater]}")"
    dict[updater_file]="$(koopa_kebab_case_simple "${dict[updater]}")"
    dict[updater_file]="${dict[installers_prefix]}/\
${dict[platform]}/${dict[updater_file]}.sh"
    koopa_assert_is_file "${dict[updater_file]}"
    # shellcheck source=/dev/null
    source "${dict[updater_file]}"
    dict[function]="$(koopa_snake_case_simple "${dict[updater]}")"
    if [[ "${dict[platform]}" != 'common' ]]
    then
        dict[function]="${dict[platform]}_${dict[function]}"
    fi
    dict[function]="${dict[function]}"
    koopa_assert_is_function "${dict[function]}"
    if [[ -z "${dict[prefix]}" ]] && [[ "${dict[system]}" -eq 0 ]]
    then
        dict[prefix]="${dict[opt_prefix]}/${dict[name]}"
    fi
    if [[ -n "${dict[prefix]}" ]]
    then
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_warn "${dict[name_fancy]} is not installed \
at '${dict[prefix]}'."
            return 1
        fi
        dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
        koopa_alert_update_start "${dict[name_fancy]}" "${dict[prefix]}"
    else
        koopa_alert_update_start "${dict[name_fancy]}"
    fi
    if koopa_is_linux && \
        { [[ "${dict[shared]}" -eq 1 ]] || \
            [[ "${dict[system]}" -eq 1 ]]; }
    then
        koopa_linux_update_ldconfig
    fi
    (
        koopa_cd "${dict[tmp_dir]}"
        unset -v LD_LIBRARY_PATH PKG_CONFIG_PATH
        PATH="$(koopa_paste --sep=':' "${clean_path_arr[@]}")"
        export PATH
        if [[ -x '/usr/bin/pkg-config' ]]
        then
            koopa_add_to_pkg_config_path_start_2 \
                '/usr/bin/pkg-config'
        fi
        # Activate packages installed in Homebrew 'opt/' directory.
        if koopa_is_array_non_empty "${homebrew_opt_arr[@]:-}"
        then
            koopa_activate_homebrew_opt_prefix "${homebrew_opt_arr[@]}"
        fi
        # Activate packages installed in Koopa 'opt/' directory.
        if koopa_is_array_non_empty "${opt_arr[@]:-}"
        then
            koopa_activate_opt_prefix "${opt_arr[@]}"
        fi
        # shellcheck disable=SC2030
        export UPDATE_PREFIX="${dict[prefix]}"
        "${dict[function]}" "$@"
    )
    koopa_rm "${dict[tmp_dir]}"
    if [[ -d "${dict[prefix]}" ]] && [[ "${dict[system]}" -eq 0 ]]
    then
        if [[ "${dict[shared]}" -eq 1 ]]
        then
            koopa_sys_set_permissions --recursive "${dict[prefix]}"
        fi
        # > koopa_delete_empty_dirs "${dict[prefix]}"
    fi
    if koopa_is_linux && \
        { [[ "${dict[shared]}" -eq 1 ]] || \
            [[ "${dict[system]}" -eq 1 ]]; }
    then
        koopa_linux_update_ldconfig
    fi
    if [[ -d "${dict[prefix]}" ]]
    then
        koopa_alert_update_success "${dict[name_fancy]}" "${dict[prefix]}"
    else
        koopa_alert_update_success "${dict[name_fancy]}"
    fi
    return 0
}
