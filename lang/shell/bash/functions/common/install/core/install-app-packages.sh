#!/usr/bin/env bash

koopa::install_app_packages() { # {{{1
    # """
    # Install application packages.
    # @note Updated 2021-11-17.
    # """
    local name name_fancy pos
    koopa::assert_has_args "$#"
    declare -A dict
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
    dict[prefix_fun]="koopa::${dict[name]}_packages_prefix"
    koopa::assert_is_function "${dict[prefix_fun]}"
    koopa::install_app \
        --name-fancy="${dict[name_fancy]} packages" \
        --name="${dict[name]}-packages" \
        --no-link \
        --no-prefix-check \
        --prefix="$("${dict[prefix_fun]}")" \
        --version='rolling' \
        "$@"
    return 0
}
