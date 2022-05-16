#!/usr/bin/env bash

koopa_invalid_arg() {
    # """
    # Error on invalid argument.
    # @note Updated 2022-02-17.
    # """
    local arg str
    if [[ "$#" -gt 0 ]]
    then
        arg="${1:-}"
        str="Invalid argument: '${arg}'."
    else
        str='Invalid argument.'
    fi
    koopa_stop "$str"
}
