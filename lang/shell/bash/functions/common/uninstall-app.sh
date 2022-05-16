#!/usr/bin/env bash

koopa_uninstall_app() {
    # """
    # Uninstall an application.
    # @note Updated 2022-05-16.
    # """
    local bin_arr dict
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [make_prefix]="$(koopa_make_prefix)"
        [mode]='shared'
        [name]=''
        [name_fancy]=''
        [opt_prefix]="$(koopa_opt_prefix)"
        [platform]='common'
        [prefix]=''
        [quiet]=0
        [uninstaller_bn]=''
        [uninstaller_fun]='main'
        [unlink_in_bin]=0
        [unlink_in_make]=0
        [unlink_in_opt]=1
        [verbose]=0
    )
    bin_arr=()
    while (("$#"))
    do
        case "$1" in
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
            '--uninstaller='*)
                dict[uninstaller_bn]="${1#*=}"
                shift 1
                ;;
            '--uninstaller')
                dict[uninstaller_bn]="${2:?}"
                shift 2
                ;;
            '--unlink-in-bin='*)
                bin_arr+=("${1#*=}")
                shift 1
                ;;
            '--unlink-in-bin')
                bin_arr+=("${2:?}")
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--no-unlink-in-opt')
                dict[unlink_in_opt]=0
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
            '--unlink-in-make')
                dict[unlink_in_make]=1
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
    koopa_assert_is_set '--name' "${dict[name]}"
    [[ "${dict[verbose]}" -eq 1 ]] && set -o xtrace
    case "${dict[mode]}" in
        'shared')
            dict[unlink_in_opt]=1
            if [[ -z "${dict[prefix]}" ]]
            then
                dict[prefix]="${dict[app_prefix]}/${dict[name]}"
            fi
            ;;
        'system')
            koopa_assert_is_admin
            dict[unlink_in_opt]=0
            ;;
        'user')
            dict[unlink_in_opt]=0
            ;;
    esac
    koopa_is_array_non_empty "${bin_arr[@]:-}" && dict[unlink_in_bin]=1
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
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_uninstall_start "${dict[name_fancy]}" "${dict[prefix]}"
        else
            koopa_alert_uninstall_start "${dict[name_fancy]}"
        fi
    fi
    [[ -z "${dict[uninstaller_bn]}" ]] && dict[uninstaller_bn]="${dict[name]}"
    dict[uninstaller_file]="${dict[installers_prefix]}/${dict[platform]}/\
${dict[mode]}/uninstall-${dict[uninstaller_bn]}.sh"
    if [[ -f "${dict[uninstaller_file]}" ]]
    then
        dict[tmp_dir]="$(koopa_tmp_dir)"
        (
            koopa_cd "${dict[tmp_dir]}"
            # shellcheck source=/dev/null
            source "${dict[uninstaller_file]}"
            koopa_assert_is_function "${dict[uninstaller_fun]}"
            "${dict[uninstaller_fun]}"
        )
        koopa_rm "${dict[tmp_dir]}"
    fi
    if [[ -d "${dict[prefix]}" ]]
    then
        case "${dict[mode]}" in
            'system')
                koopa_rm --sudo "${dict[prefix]}"
                ;;
            *)
                koopa_rm "${dict[prefix]}"
                ;;
        esac
    fi
    if [[ "${dict[unlink_in_bin]}" -eq 1 ]]
    then
        koopa_unlink_in_bin "${bin_arr[@]}"
    fi
    if [[ "${dict[unlink_in_opt]}" -eq 1 ]]
    then
        koopa_unlink_in_opt "${dict[name]}"
    fi
    if [[ "${dict[unlink_in_make]}" -eq 1 ]]
    then
        koopa_unlink_in_make "${dict[prefix]}"
    fi
    if [[ "${dict[quiet]}" -eq 0 ]]
    then
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_alert_uninstall_success \
                "${dict[name_fancy]}" "${dict[prefix]}"
        else
            koopa_alert_uninstall_success "${dict[name_fancy]}"
        fi
    fi
    return 0
}
