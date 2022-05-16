#!/usr/bin/env bash

koopa_read_prompt_yn() {
    # """
    # Show colorful yes/no default choices in prompt.
    # @note Updated 2022-02-01.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        [input]="${2:?}"
        [no]="$(koopa_print_red 'no')"
        [no_default]="$(koopa_print_red_bold 'NO')"
        [prompt]="${1:?}"
        [yes]="$(koopa_print_green 'yes')"
        [yes_default]="$(koopa_print_green_bold 'YES')"
    )
    case "${dict[input]}" in
        '0')
            dict[yn]="${dict[yes]}/${dict[no_default]}"
            ;;
        '1')
            dict[yn]="${dict[yes_default]}/${dict[no]}"
            ;;
        *)
            koopa_stop "Invalid choice: requires '0' or '1'."
            ;;
    esac
    koopa_print "${dict[prompt]}? [${dict[yn]}]: "
    return 0
}
