#!/usr/bin/env bash

_koopa_header() {
    # """
    # Shared language-specific header file.
    # @note Updated 2023-12-05.
    #
    # Useful for private scripts using koopa code outside of package.
    #
    # @examples
    # _koopa_header 'bash'
    # _koopa_header 'posix'
    # _koopa_header 'sh'
    # _koopa_header 'zsh'
    # """
    local -A dict
    _koopa_assert_has_args_eq "$#" 1
    dict['lang']="$(_koopa_lowercase "${1:?}")"
    case "${dict['lang']}" in
        'posix')
            dict['lang']='sh'
            ;;
    esac
    dict['prefix']="$(_koopa_koopa_prefix)/lang/${dict['lang']}"
    case "${dict['lang']}" in
        'bash' | \
        'sh' | \
        'zsh')
            dict['ext']='sh'
            ;;
        *)
            _koopa_invalid_arg "${dict['lang']}"
            ;;
    esac
    dict['file']="${dict['prefix']}/include/header.${dict['ext']}"
    _koopa_assert_is_file "${dict['file']}"
    _koopa_print "${dict['file']}"
    return 0
}
