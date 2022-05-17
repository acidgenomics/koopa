#!/usr/bin/env bash

koopa_configure_app_packages() {
    # """
    # Configure language application.
    # @note Updated 2022-04-21.
    #
    # @examples
    # > koopa_configure_app_packages \
    # >     --app='/opt/koopa/app/python/3.10.3/bin/python3'
    # >     --name-fancy='Python' \
    # >     --name='python'
    # > koopa_configure_app_packages \
    # >     --name-fancy='Python' \
    # >     --name='python' \
    # >     --version='3.10.3'
    # > koopa_configure_app_packages \
    # >     --name-fancy='Python3' \
    # >     --name='python' \
    # >     --prefix='/opt/koopa/app/python-packages/3.10'
    # """
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app]=''
        [link_in_opt]=1
        [name]=''
        [name_fancy]=''
        [prefix]=''
        [version]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--app='*)
                dict[app]="${1#*=}"
                shift 1
                ;;
            '--app')
                dict[app]="${2:?}"
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
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
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
            '--link-in-opt')
                dict[link_in_opt]=1
                shift 1
                ;;
            '--no-link-in-opt')
                dict[link_in_opt]=0
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -gt 0 ]]
    then
        koopa_assert_has_args_eq "$#" 1
        dict[app]="${1:?}"
    fi
    koopa_assert_is_set '--name' "${dict[name]}"
    if [[ -z "${dict[name_fancy]}" ]]
    then
        dict[name_fancy]="${dict[name]}"
    fi
    dict[pkg_prefix_fun]="koopa_${dict[name]}_packages_prefix"
    koopa_assert_is_function "${dict[pkg_prefix_fun]}"
    if [[ -z "${dict[prefix]}" ]]
    then
        if [[ -z "${dict[version]}" ]]
        then
            if [[ -z "${dict[app]}" ]]
            then
                dict[locate_app_fun]="koopa_locate_${dict[name]}"
                koopa_assert_is_function "${dict[locate_app_fun]}"
                dict[app]="$("${dict[locate_app_fun]}")"
            fi
            koopa_assert_is_installed "${dict[app]}"
            dict[version]="$(koopa_get_version "${dict[app]}")"
        fi
        dict[prefix]="$("${dict[pkg_prefix_fun]}" "${dict[version]}")"
    fi
    koopa_alert_configure_start "${dict[name_fancy]}" "${dict[prefix]}"
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa_sys_mkdir "${dict[prefix]}"
        koopa_sys_set_permissions "$(koopa_dirname "${dict[prefix]}")"
    fi
    if [[ "${dict[link_in_opt]}" -eq 1 ]]
    then
        koopa_link_in_opt "${dict[prefix]}" "${dict[name]}-packages"
    fi
    koopa_alert_configure_success "${dict[name_fancy]}" "${dict[prefix]}"
    return 0
}
