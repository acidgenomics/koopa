#!/usr/bin/env bash

koopa::uninstall() { # {{{1
    # """
    # Uninstall commands.
    # @note Updated 2020-11-18.
    # """
    local fun name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        koopa::stop 'Program name to uninstall is required.'
    fi
    fun="koopa::uninstall_${name//-/_}"
    if ! koopa::is_function "$fun"
    then
        koopa::stop "No uninstall script available for '${*}'."
    fi
    shift 1
    "$fun" "$@"
    return 0
}

koopa::uninstall_koopa() { # {{{1
    # """
    # Uninstall koopa.
    # @note Updated 2020-06-24.
    # """
    "$(koopa::prefix)/uninstall" "$@"
    return 0
}
