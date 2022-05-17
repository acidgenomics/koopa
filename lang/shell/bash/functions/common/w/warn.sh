#!/usr/bin/env bash

koopa_warn() {
    # """
    # Warning message.
    # @note Updated 2022-02-24.
    # """
    __koopa_msg 'magenta-bold' 'magenta' '!!' "$@" >&2
    return 0
}
