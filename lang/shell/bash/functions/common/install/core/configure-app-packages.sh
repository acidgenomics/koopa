#!/usr/bin/env bash

koopa:::configure_app_packages() { # {{{1
    # """
    # Configure language application.
    # @note Updated 2021-09-21.
    # """
    local dict
    declare -A dict=(
        [link_app]=1
        [name]=''
        [name_fancy]=''
        [prefix]=''
        [version]=''
        [which_app]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
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
            '--which-app='*)
                dict[which_app]="${1#*=}"
                shift 1
                ;;
            '--which-app')
                dict[which_app]="${2:?}"
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
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${dict[name_fancy]}" ]]
    then
        dict[name_fancy]="${dict[name]}"
    fi
    dict[pkg_prefix_fun]="koopa::${dict[name]}_packages_prefix"
    koopa::assert_is_function "${dict[pkg_prefix_fun]}"
    if [[ -z "${dict[prefix]}" ]]
    then
        if [[ -z "${dict[version]}" ]]
        then
            dict[version]="$(koopa::get_version "${dict[which_app]}")"
        fi
        dict[prefix]="$("${dict[pkg_prefix_fun]}" "${dict[version]}")"
    fi
    koopa::configure_start "${dict[name_fancy]}" "${dict[prefix]}"
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa::sys_mkdir "${dict[prefix]}"
        koopa::sys_set_permissions "$(koopa::dirname "${dict[prefix]}")"
    fi
    if [[ "${dict[link_app]}" -eq 1 ]]
    then
        koopa::link_into_opt "${dict[prefix]}" "${dict[name]}-packages"
    fi
    koopa::configure_success "${dict[name_fancy]}" "${dict[prefix]}"
    return 0
}
