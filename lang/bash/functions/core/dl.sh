#!/usr/bin/env bash

_koopa_dl() {
    # """
    # Definition list.
    # @note Updated 2023-06-29.
    # """
    _koopa_assert_has_args_ge "$#" 2
    while [[ "$#" -ge 2 ]]
    do
        _koopa_msg 'default' 'default' "${1:?}:" "${2:-}"
        shift 2
    done
    return 0
}
