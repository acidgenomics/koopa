#!/usr/bin/env bash

koopa_header() {
    # """
    # Shared language-specific header file.
    # @note Updated 2023-12-05.
    #
    # Useful for private scripts using koopa code outside of package.
    #
    # @examples
    # koopa_header 'bash'
    # koopa_header 'posix'
    # koopa_header 'sh'
    # koopa_header 'zsh'
    # """
    local -A dict
    koopa_assert_has_args_eq "$#" 1
    dict['lang']="$(koopa_lowercase "${1:?}")"
    case "${dict['lang']}" in
        'posix')
            dict['lang']='sh'
            ;;
    esac
    dict['prefix']="$(koopa_koopa_prefix)/lang/${dict['lang']}"
    case "${dict['lang']}" in
        'bash' | \
        'sh' | \
        'zsh')
            dict['ext']='sh'
            ;;
        *)
            koopa_invalid_arg "${dict['lang']}"
            ;;
    esac
    dict['file']="${dict['prefix']}/include/header.${dict['ext']}"
    koopa_assert_is_file "${dict['file']}"
    koopa_print "${dict['file']}"
    return 0
}
