#!/usr/bin/env bash

koopa_defunct() {
    # """
    # Make a function defunct.
    # @note Updated 2020-02-18.
    # """
    local msg new
    new="${1:-}"
    msg='Defunct.'
    if [[ -n "$new" ]]
    then
        msg="${msg} Use '${new}' instead."
    fi
    koopa_stop "${msg}"
}
