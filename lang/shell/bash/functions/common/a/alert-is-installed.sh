#!/usr/bin/env bash

koopa_alert_is_installed() {
    # """
    # Alert the user that a program is installed.
    # @note Updated 2022-04-11.
    # """
    local name prefix
    name="${1:?}"
    prefix="${2:-}"
    x="${name} is installed"
    if [[ -n "$prefix" ]]
    then
        x="${x} at '${prefix}'"
    fi
    x="${x}."
    koopa_alert_note "$x"
    return 0
}
