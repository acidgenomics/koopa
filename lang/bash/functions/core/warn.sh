#!/usr/bin/env bash

_koopa_warn() {
    # """
    # Warning message.
    # @note Updated 2022-02-24.
    # """
    _koopa_msg 'magenta-bold' 'magenta' '!!' "$@" >&2
    return 0
}
