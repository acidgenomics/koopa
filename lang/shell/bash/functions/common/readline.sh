#!/usr/bin/env bash

koopa:::int_to_yn() { # {{{1
    # """
    # Convert integer to yes/no choice.
    # @note Updated 2022-02-09.
    # """
    local str
    koopa::assert_has_args_eq "$#" 1
    case "${1:?}" in
        '0')
            str='no'
            ;;
        '1')
            str='yes'
            ;;
        *)
            koopa::stop "Invalid choice: requires '0' or '1'."
            ;;
    esac
    koopa::print "$str"
    return 0
}

koopa:::read_prompt_yn() { # {{{1
    # """
    # Show colorful yes/no default choices in prompt.
    # @note Updated 2022-02-01.
    # """
    local dict
    koopa::assert_has_args_eq "$#" 2
    declare -A dict=(
        [input]="${2:?}"
        [no]="$(koopa::print_red 'no')"
        [no_default]="$(koopa::print_red_bold 'NO')"
        [prompt]="${1:?}"
        [yes]="$(koopa::print_green 'yes')"
        [yes_default]="$(koopa::print_green_bold 'YES')"
    )
    case "${dict[input]}" in
        '0')
            dict[yn]="${dict[yes]}/${dict[no_default]}"
            ;;
        '1')
            dict[yn]="${dict[yes_default]}/${dict[no]}"
            ;;
        *)
            koopa::stop "Invalid choice: requires '0' or '1'."
            ;;
    esac
    koopa::print "${dict[prompt]}? [${dict[yn]}]: "
    return 0
}

koopa::read() { # {{{1
    # """
    # Read a string from the user.
    # @note Updated 2022-02-01.
    # """
    local dict read_args
    koopa::assert_has_args_eq "$#" 2
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
    koopa::print "${dict[choice]}"
    return 0
}

koopa::read_yn() { # {{{1
    # """
    # Read a yes/no choice from the user.
    # @note Updated 2022-02-01.
    # """
    local dict read_args
    koopa::assert_has_args_eq "$#" 2
    declare -A dict
    dict[prompt]="$(koopa:::read_prompt_yn "$@")"
    dict[default]="$(koopa:::int_to_yn "${2:?}")"
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
            koopa::stop "Invalid 'yes/no' choice: '${dict[choice]}'."
            ;;
    esac
    koopa::print "${dict[int]}"
    return 0
}
