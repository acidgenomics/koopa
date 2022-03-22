#!/usr/bin/env bash

koopa_int_to_yn() { # {{{1
    # """
    # Convert integer to yes/no choice.
    # @note Updated 2022-02-09.
    # """
    local str
    koopa_assert_has_args_eq "$#" 1
    case "${1:?}" in
        '0')
            str='no'
            ;;
        '1')
            str='yes'
            ;;
        *)
            koopa_stop "Invalid choice: requires '0' or '1'."
            ;;
    esac
    koopa_print "$str"
    return 0
}

koopa_read() { # {{{1
    # """
    # Read a string from the user.
    # @note Updated 2022-02-01.
    # """
    local dict read_args
    koopa_assert_has_args_eq "$#" 2
    declare -A dict
    dict[default]="${2:?}"
    dict[prompt]="${1:?} [${dict[default]}]: "
    read_args=(
        -e
        -i "${dict[default]}"
        -p "${dict[prompt]}"
        -r
    )
    # shellcheck disable=SC2162
    read "${read_args[@]}" "dict[choice]"
    [[ -z "${dict[choice]}" ]] && dict[choice]="${dict[default]}"
    koopa_print "${dict[choice]}"
    return 0
}

koopa_read_prompt_yn() { # {{{1
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

koopa_read_yn() { # {{{1
    # """
    # Read a yes/no choice from the user.
    # @note Updated 2022-02-01.
    # """
    local dict read_args
    koopa_assert_has_args_eq "$#" 2
    declare -A dict
    dict[prompt]="$(koopa_read_prompt_yn "$@")"
    dict[default]="$(koopa_int_to_yn "${2:?}")"
    read_args=(
        -e
        -i "${dict[default]}"
        -p "${dict[prompt]}"
        -r
    )
    # shellcheck disable=SC2162
    read "${read_args[@]}" "dict[choice]"
    [[ -z "${dict[choice]}" ]] && dict[choice]="${dict[default]}"
    case "${dict[choice]}" in
        '1' | \
        'T' | \
        'TRUE' | \
        'True' | \
        'Y' | \
        'YES' | \
        'Yes' | \
        'true' | \
        'y' | \
        'yes')
            dict[int]=1
            ;;
        '0' | \
        'F' | \
        'FALSE' | \
        'False' | \
        'N' | \
        'NO' | \
        'No' | \
        'false' | \
        'n' | \
        'no')
            dict[int]=0
            ;;
        *)
            koopa_stop "Invalid 'yes/no' choice: '${dict[choice]}'."
            ;;
    esac
    koopa_print "${dict[int]}"
    return 0
}
