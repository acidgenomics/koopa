#!/usr/bin/env bash

_koopa_h() {
    # """
    # Header message generator.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    _koopa_assert_has_args_ge "$#" 2
    dict['emoji']="$(_koopa_acid_emoji)"
    dict['level']="${1:?}"
    shift 1
    case "${dict['level']}" in
        '1')
            _koopa_print ''
            dict['prefix']='#'
            ;;
        '2')
            dict['prefix']='##'
            ;;
        '3')
            dict['prefix']='###'
            ;;
        '4')
            dict['prefix']='####'
            ;;
        '5')
            dict['prefix']='#####'
            ;;
        '6')
            dict['prefix']='######'
            ;;
        '7')
            dict['prefix']='#######'
            ;;
        *)
            _koopa_stop 'Invalid header level.'
            ;;
    esac
    _koopa_msg 'magenta' 'default' "${dict['emoji']} ${dict['prefix']}" "$@"
    return 0
}
