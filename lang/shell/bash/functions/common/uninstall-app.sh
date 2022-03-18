#!/usr/bin/env bash

# FIXME Need to support removal of older app versions.
# FIXME In the case where it's not current link in opt, don't remove the opt link.

koopa_uninstall_app() { # {{{1
    # """
    # Uninstall an application.
    # @note Updated 2022-02-25.
    # """
    local app dict pos
    declare -A app
    declare -A dict=(
        [app_prefix]="$(koopa_app_prefix)"
        [installers_prefix]="$(koopa_installers_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [link_app]=1
        [make_prefix]="$(koopa_make_prefix)"
        [name_fancy]=''
        [opt_prefix]="$(koopa_opt_prefix)"
        [platform]='common'
        [prefix]=''
        [quiet]=0
        [shared]=0
        [system]=0
        [uninstaller]=''
    )
    pos=()
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
                dict[uninstaller]="${1#*=}"
                shift 1
                ;;
            '--uninstaller')
                dict[uninstaller]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--link')
                dict[link_app]=1
                shift 1
                ;;
            '--no-link')
                dict[link_app]=0
                shift 1
                ;;
            '--quiet')
                dict[quiet]=1
                shift 1
                ;;
            '--system')
                dict[system]=1
                shift 1
                ;;
            '--verbose')
                set -x
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
    if [[ "${dict[shared]}" -eq 0 ]] || koopa_is_macos
    then
        dict[link_app]=0
    fi
    if [[ "${dict[system]}" -eq 1 ]]
    then
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert_uninstall_start "${dict[name_fancy]}"
        fi
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa_rm --sudo "${dict[prefix]}"
        else
            [[ -z "${dict[uninstaller]}" ]] && dict[uninstaller]="${dict[name]}"
            dict[uninstaller]="$( \
                koopa_snake_case_simple "uninstall_${dict[uninstaller]}" \
            )"
            dict[uninstaller_file]="$( \
                koopa_kebab_case_simple "${dict[uninstaller]}" \
            )"
            dict[uninstaller_file]="${dict[installers_prefix]}/\
${dict[platform]}/${dict[uninstaller_file]}.sh"
            koopa_assert_is_file "${dict[uninstaller_file]}"
            # shellcheck source=/dev/null
            source "${dict[uninstaller_file]}"
            dict[function]="$(koopa_snake_case_simple "${dict[uninstaller]}")"
            if [[ "${dict[platform]}" != 'common' ]]
            then
                dict[function]="${dict[platform]}_${dict[function]}"
            fi
            dict[function]="${dict[function]}"
            koopa_assert_is_function "${dict[function]}"
            "${dict[function]}" "$@"
        fi
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert_uninstall_success "${dict[name_fancy]}"
        fi
    else
        koopa_assert_has_no_args "$#"
        if [[ -z "${dict[prefix]}" ]]
        then
            dict[prefix]="${dict[app_prefix]}/${dict[name]}"
        fi
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa_warn "${dict[name_fancy]} is not installed \
at '${dict[prefix]}'."
            return 1
        fi
        if [[ "${dict[shared]}" -eq 1 ]]
        then
            app[rm]='koopa_sys_rm'
        else
            app[rm]='koopa_rm'
        fi
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert_uninstall_start \
                "${dict[name_fancy]}" "${dict[prefix]}"
        fi
        "${app[rm]}" "${dict[prefix]}"
        if [[ "${dict[shared]}" -eq 1 ]]
        then
            "${app[rm]}" "${dict[opt_prefix]}/${dict[name]}"
        fi
        if [[ "${dict[link_app]}" -eq 1 ]]
        then
            koopa_delete_broken_symlinks "${dict[make_prefix]}"
        fi
        if [[ "${dict[quiet]}" -eq 0 ]]
        then
            koopa_alert_uninstall_success \
                "${dict[name_fancy]}" "${dict[prefix]}"
        fi
    fi
    return 0
}
