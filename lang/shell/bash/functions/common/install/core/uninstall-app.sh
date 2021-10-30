#!/usr/bin/env bash

# FIXME Need to migrate tee, tmp_dir, etc. into array.
# FIXME Need to add support for '--system' and '--platform'.

koopa:::uninstall_app() { # {{{1
    # """
    # Uninstall an application.
    # @note Updated 2021-09-21.
    # """
    local dict pos rm
    declare -A dict=(
        [app_prefix]="$(koopa::app_prefix)"
        [koopa_prefix]="$(koopa::koopa_prefix)"
        [link_app]=''
        [make_prefix]="$(koopa::make_prefix)"
        [name_fancy]=''
        [opt_prefix]="$(koopa::opt_prefix)"
        [prefix]=''
        [shared]=0
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
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_no_args "$#"
    if [[ -z "${dict[name_fancy]}" ]]
    then
        dict[name_fancy]="${dict[name]}"
    fi
    if [[ -z "${dict[prefix]}" ]]
    then
        dict[prefix]="${dict[app_prefix]}/${dict[name]}"
    fi
    if [[ ! -d "${dict[prefix]}" ]]
    then
        koopa::alert_is_not_installed "${dict[name_fancy]}" "${dict[prefix]}"
        return 0
    fi
    if koopa::str_match_regex "${dict[prefix]}" "^${dict[koopa_prefix]}"
    then
        dict[shared]=1
    fi
    if [[ "${dict[shared]}" -eq 1 ]]
    then
        rm='koopa::sys_rm'
    else
        rm='koopa::rm'
    fi
    if [[ -z "${dict[link_app]}" ]]
    then
        if [[ "${dict[shared]}" -eq 0 ]] || koopa::is_macos
        then
            dict[link_app]=0
        else
            dict[link_app]=1
        fi
    fi
    koopa::uninstall_start "${dict[name_fancy]}" "${dict[prefix]}"
    "$rm" \
        "${dict[prefix]}" \
        "${dict[opt_prefix]}/${dict[name]}"
    if [[ "${dict[link_app]}" -eq 1 ]]
    then
        koopa::alert "Deleting broken symlinks in '${dict[make_prefix]}'."
        koopa::delete_broken_symlinks "${dict[make_prefix]}"
    fi
    koopa::uninstall_success "${dict[name_fancy]}"
    return 0
}
