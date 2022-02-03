#!/usr/bin/env bash

koopa::install_app_packages() { # {{{1
    # """
    # Install application packages.
    # @note Updated 2022-02-03.
    # """
    local name name_fancy pos
    koopa::assert_has_args "$#"
    declare -A dict=(
        [name]=''
        [name_fancy]=''
        [reinstall]=0
    )
    pos=()
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
            # Flags ------------------------------------------------------------
            '--reinstall')
                dict[reinstall]=1
                shift 1
                ;;
            # Internally defined arguments -------------------------------------
            '--prefix='* | \
            '--prefix' | \
            '--version='* | \
            '--version' | \
            '--link' | \
            '--no-link' | \
            '--no-prefix-check' | \
            '--prefix-check')
                koopa::invalid_arg "$1"
                ;;
            # Other ------------------------------------------------------------
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_is_set \
        '--name' "${dict[name]}"
    dict[prefix_fun]="koopa::${dict[name]}_packages_prefix"
    koopa::assert_is_function "${dict[prefix_fun]}"
    dict[prefix]="$("${dict[prefix_fun]}")"
    if [[ -d "${dict[prefix]}" ]]
    then
        dict[prefix]="$(koopa::realpath "${dict[prefix]}")"
    fi
    if [[ "${dict[reinstall]}" -eq 1 ]]
    then
        koopa::sys_rm "${dict[prefix]}"
    fi
    koopa::install_app \
        --name-fancy="${dict[name_fancy]} packages" \
        --name="${dict[name]}-packages" \
        --no-link \
        --no-prefix-check \
        --prefix="${dict[prefix]}" \
        --version='rolling' \
        "$@"
    return 0
}
