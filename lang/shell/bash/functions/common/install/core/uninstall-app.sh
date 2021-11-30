#!/usr/bin/env bash

koopa::uninstall_app() { # {{{1
    # """
    # Uninstall an application.
    # @note Updated 2021-11-24.
    # """
    local app dict pos
    declare -A app
    declare -A dict=(
        [app_prefix]="$(koopa::app_prefix)"
        [function]=''
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [link_app]=''
        [make_prefix]="$(koopa::make_prefix)"
        [name_fancy]=''
        [opt_prefix]="$(koopa::opt_prefix)"
        [platform]=''
        [prefix]=''
        [shared]=0
        [system]=0
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
            # Flags ------------------------------------------------------------
            '--link')
                dict[link_app]=1
                shift 1
                ;;
            '--no-link')
                dict[link_app]=0
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
    if [[ "${dict[system]}" -eq 1 ]]
    then
        koopa::alert_uninstall_start "${dict[name_fancy]}"
        if [[ -n "${dict[prefix]}" ]]
        then
            koopa::rm --sudo "${dict[prefix]}"
        else
            dict[function]="$(koopa::snake_case_simple "${dict[name]}")"
            dict[function]="uninstall_${dict[function]}"
            if [[ -n "${dict[platform]}" ]]
            then
                dict[function]="${dict[platform]}_${dict[function]}"
            fi
            dict[function]="koopa:::${dict[function]}"
            if ! koopa::is_function "${dict[function]}"
            then
                koopa::stop 'Unsupported command.'
            fi
            "${dict[function]}" "$@"
        fi
        koopa::alert_uninstall_success "${dict[name_fancy]}"
    else
        koopa::assert_has_no_args "$#"
        if [[ -z "${dict[prefix]}" ]]
        then
            dict[prefix]="${dict[app_prefix]}/${dict[name]}"
        fi
        if [[ ! -d "${dict[prefix]}" ]]
        then
            koopa::alert_is_not_installed \
                "${dict[name_fancy]}" \
                "${dict[prefix]}"
            return 0
        fi
        if koopa::str_match_regex \
            "${dict[prefix]}" \
            "^${dict[koopa_prefix]}"
        then
            dict[shared]=1
        fi
        koopa::alert_uninstall_start "${dict[name_fancy]}" "${dict[prefix]}"
        if [[ "${dict[shared]}" -eq 1 ]]
        then
            app[rm]='koopa::sys_rm'
        else
            app[rm]='koopa::rm'
        fi
        "${app[rm]}" \
            "${dict[prefix]}" \
            "${dict[opt_prefix]}/${dict[name]}"
        if [[ -z "${dict[link_app]}" ]]
        then
            if [[ "${dict[shared]}" -eq 0 ]] || koopa::is_macos
            then
                dict[link_app]=0
            else
                dict[link_app]=1
            fi
        fi
        if [[ "${dict[link_app]}" -eq 1 ]]
        then
            koopa::alert "Deleting broken symlinks in '${dict[make_prefix]}'."
            koopa::delete_broken_symlinks "${dict[make_prefix]}"
        fi
        koopa::alert_uninstall_success "${dict[name_fancy]}" "${dict[prefix]}"
    fi
    return 0
}
