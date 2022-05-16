#!/usr/bin/env bash

koopa_run_if_installed() {
    # """
    # Run program(s) if installed.
    # @note Updated 2020-06-30.
    # """
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        local exe
        if ! koopa_is_installed "$arg"
        then
            koopa_alert_note "Skipping '${arg}'."
            continue
        fi
        exe="$(koopa_which_realpath "$arg")"
        "$exe"
    done
    return 0
}
