#!/usr/bin/env bash

koopa_alert_is_installed() {
    # """
    # Alert the user that a program is installed.
    # @note Updated 2023-04-05.
    # """
    local -A dict
    dict['name']="${1:?}"
    dict['prefix']="${2:-}"
    dict['string']="'${dict['name']}' is installed"
    if [[ -n "${dict['prefix']}" ]]
    then
        dict['string']="${dict['string']} at '${dict['prefix']}'"
    fi
    dict['string']="${dict['string']}."
    koopa_alert_note "${dict['string']}"
    return 0
}
