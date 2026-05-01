#!/usr/bin/env bash

_koopa_run_if_installed() {
    # """
    # Run program(s) if installed.
    # @note Updated 2020-06-30.
    # """
    local arg
    _koopa_assert_has_args "$#"
    for arg in "$@"
    do
        local exe
        if ! _koopa_is_installed "$arg"
        then
            _koopa_alert_note "Skipping '${arg}'."
            continue
        fi
        exe="$(_koopa_which_realpath "$arg")"
        "$exe"
    done
    return 0
}
