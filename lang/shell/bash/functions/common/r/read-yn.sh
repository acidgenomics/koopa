#!/usr/bin/env bash

koopa_read_yn() {
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
