#!/usr/bin/env bash

koopa_install_app_internal() {
    # """
    # Internal runner to install an application.
    # @note Updated 2022-08-12.
    # """
    local pos
    koopa_assert_has_args "$#"
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--link-in-bin' | \
            '--link-in-bin='* | \
            '--no-link-in-opt' | \
            '--no-prefix-check' | \
            '--quiet' | \
            '--no-restrict-path')
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_install_app \
        --no-link-in-opt \
        --no-prefix-check \
        --no-restrict-path \
        --quiet \
        "$@"
}
