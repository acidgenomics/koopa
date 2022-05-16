#!/usr/bin/env bash

koopa_header() {
    # """
    # Shared language-specific header file.
    # @note Updated 2022-02-15.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        [lang]="$(koopa_lowercase "${1:?}")"
        [prefix]="$(koopa_koopa_prefix)/lang"
    )
    case "${dict[lang]}" in
        'bash' | \
        'posix' | \
        'zsh')
            dict[prefix]="${dict[prefix]}/shell"
            dict[ext]='sh'
            ;;
        'r')
            dict[ext]='R'
            ;;
        *)
            koopa_invalid_arg "${dict[lang]}"
            ;;
    esac
    dict[file]="${dict[prefix]}/${dict[lang]}/include/header.${dict[ext]}"
    koopa_assert_is_file "${dict[file]}"
    koopa_print "${dict[file]}"
    return 0
}
