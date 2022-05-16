#!/usr/bin/env bash

koopa_stop() {
    # """
    # Stop with an error message.
    # @note Updated 2022-04-11.
    # """
    __koopa_msg 'red-bold' 'red' '!! Error:' "$@" >&2
    exit 1
}
