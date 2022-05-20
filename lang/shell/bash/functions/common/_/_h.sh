#!/usr/bin/env bash

__koopa_h() {
    # """
    # Header message generator.
    # @note Updated 2022-01-20.
    # """
    local dict
    koopa_assert_has_args_ge "$#" 2
    declare -A dict=(
        [emoji]="$(koopa_acid_emoji)"
        [level]="${1:?}"
    )
    shift 1
    case "${dict[level]}" in
        '1')
            koopa_print ''
            dict[prefix]='#'
            ;;
        '2')
            dict[prefix]='##'
            ;;
        '3')
            dict[prefix]='###'
            ;;
        '4')
            dict[prefix]='####'
            ;;
        '5')
            dict[prefix]='#####'
            ;;
        '6')
            dict[prefix]='######'
            ;;
        '7')
            dict[prefix]='#######'
            ;;
        *)
            koopa_stop 'Invalid header level.'
            ;;
    esac
    __koopa_msg 'magenta' 'default' "${dict[emoji]} ${dict[prefix]}" "$@"
    return 0
}
