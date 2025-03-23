#!/usr/bin/env bash

koopa_dl() {
    # """
    # Definition list.
    # @note Updated 2023-06-29.
    # """
    koopa_assert_has_args_ge "$#" 2
    while [[ "$#" -ge 2 ]]
    do
        koopa_msg 'default' 'default' "${1:?}:" "${2:-}"
        shift 2
    done
    return 0
}
