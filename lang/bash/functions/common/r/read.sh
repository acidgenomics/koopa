#!/usr/bin/env bash

koopa_read() {
    # """
    # Read a string from the user.
    # @note Updated 2024-06-23.
    # """
    local -A dict
    local -a read_args
    koopa_assert_has_args_eq "$#" 2
    dict['default']="${2:-}"
    dict['prompt']="${1:?} [${dict['default']}]: "
    read_args+=(
        '-e'
        '-i' "${dict['default']}"
        '-p' "${dict['prompt']}"
        '-r'
    )
    # shellcheck disable=SC2162
    read "${read_args[@]}" "dict[choice]"
    [[ -z "${dict['choice']}" ]] && dict['choice']="${dict['default']}"
    koopa_print "${dict['choice']}"
    return 0
}
