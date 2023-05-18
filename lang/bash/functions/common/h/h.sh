#!/usr/bin/env bash

koopa_h() {
    # """
    # Header message generator.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    koopa_assert_has_args_ge "$#" 2
    dict['emoji']="$(koopa_acid_emoji)"
    dict['level']="${1:?}"
    shift 1
    case "${dict['level']}" in
        '1')
            koopa_print ''
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
            koopa_stop 'Invalid header level.'
            ;;
    esac
    koopa_msg 'magenta' 'default' "${dict['emoji']} ${dict['prefix']}" "$@"
    return 0
}
