#!/usr/bin/env bash

koopa_dl() {
    # """
    # Definition list.
    # @note Updated 2022-04-01.
    # """
    koopa_assert_has_args_ge "$#" 2
    while [[ "$#" -ge 2 ]]
    do
        __koopa_msg 'default-bold' 'default' "${1:?}:" "${2:-}"
        shift 2
    done
    return 0
}
