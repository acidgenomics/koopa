#!/usr/bin/env bash

koopa_read_prompt_yn() {
    # """
    # Show colorful yes/no default choices in prompt.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    koopa_assert_has_args_eq "$#" 2
    dict['input']="${2:?}"
    dict['no']="$(koopa_print_red 'no')"
    dict['no_default']="$(koopa_print_red_bold 'NO')"
    dict['prompt']="${1:?}"
    dict['yes']="$(koopa_print_green 'yes')"
    dict['yes_default']="$(koopa_print_green_bold 'YES')"
    case "${dict['input']}" in
        '0')
            dict['yn']="${dict['yes']}/${dict['no_default']}"
            ;;
        '1')
            dict['yn']="${dict['yes_default']}/${dict['no']}"
            ;;
        *)
            koopa_stop "Invalid choice: requires '0' or '1'."
            ;;
    esac
    koopa_print "${dict['prompt']}? [${dict['yn']}]: "
    return 0
}
